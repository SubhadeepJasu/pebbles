/*
 * Copyright (C) 2020 Purism SPC
 * Copyright (C) 2020 Felipe Borges
 *
 * Authors:
 * Felipe Borges <felipeborges@gnome.org>
 * Julian Sparber <julian@sparber.net>
 *
 * SPDX-License-Identifier: LGPL-2.1+
 *
 */

#include "config.h"
#include <math.h>

#include "hdy-avatar.h"
#include "hdy-avatar-icon-private.h"
#include "hdy-cairo-private.h"
#include "hdy-css-private.h"

#define NUMBER_OF_COLORS 14
#define LOAD_BUFFER_SIZE 65536
/**
 * SECTION:hdy-avatar
 * @short_description: A widget displaying an image, with a generated fallback.
 * @Title: HdyAvatar
 *
 * #HdyAvatar is a widget to display a round avatar.
 * A provided image is made round before displaying, if no image is given this
 * widget generates a round fallback with the initials of the #HdyAvatar:text
 * on top of a colord background.
 * The color is picked based on the hash of the #HdyAvatar:text.
 * If #HdyAvatar:show-initials is set to %FALSE, `avatar-default-symbolic` is
 * shown in place of the initials.
 * Use hdy_avatar_set_loadable_icon() or #HdyAvatar:loadable-icon to set a
 * custom image.
 *
 * # CSS nodes
 *
 * #HdyAvatar has a single CSS node with name avatar.
 *
 */

struct _HdyAvatar
{
  GtkDrawingArea parent_instance;

  gchar *icon_name;
  gchar *text;
  PangoLayout *layout;
  gboolean show_initials;
  guint color_class;
  gint size;
  GdkPixbuf *round_image;

  HdyAvatarIcon *load_func_icon;
  GLoadableIcon *icon;
  GCancellable *cancellable;
  guint currently_loading_size;
  gboolean loading_error;
};

G_DEFINE_TYPE (HdyAvatar, hdy_avatar, GTK_TYPE_DRAWING_AREA);

enum {
  PROP_0,
  PROP_ICON_NAME,
  PROP_TEXT,
  PROP_SHOW_INITIALS,
  PROP_SIZE,
  PROP_LOADABLE_ICON,
  PROP_LAST_PROP,
};
static GParamSpec *props[PROP_LAST_PROP];

typedef struct {
  gint size;
  gint scale_factor;
} SizeData;

static void
size_data_free (SizeData *data)
{
  g_slice_free (SizeData, data);
}

static void
load_icon_async (HdyAvatar           *self,
                 gint                 size,
                 GCancellable        *cancellable,
                 GAsyncReadyCallback  callback,
                 gpointer             user_data);

static inline GLoadableIcon *
get_icon (HdyAvatar *self)
{
  if (self->icon)
    return self->icon;

  return G_LOADABLE_ICON (self->load_func_icon);
}

static inline gboolean
is_scaled (GdkPixbuf *pixbuf)
{
  return (pixbuf && g_object_get_data (G_OBJECT (pixbuf), "scaled") != NULL);
}

static GdkPixbuf *
make_round_image (GdkPixbuf *pixbuf,
                  gdouble    size)
{
  g_autoptr (cairo_surface_t) surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, size, size);
  g_autoptr (cairo_t) cr = cairo_create (surface);
  gint width = gdk_pixbuf_get_width (pixbuf);
  gint height = gdk_pixbuf_get_height (pixbuf);

  /* Clip a circle */
  cairo_arc (cr, size / 2.0, size / 2.0, size / 2.0, 0, 2 * G_PI);
  cairo_clip (cr);
  cairo_new_path (cr);

  gdk_cairo_set_source_pixbuf (cr, pixbuf, (size - width) / 2, (size - height) / 2);
  cairo_paint (cr);

  return gdk_pixbuf_get_from_surface (surface, 0, 0, size, size);
}

static gchar *
extract_initials_from_text (const gchar *text)
{
  GString *initials;
  g_autofree gchar *p = g_utf8_strup (text, -1);
  g_autofree gchar *normalized = g_utf8_normalize (g_strstrip (p), -1, G_NORMALIZE_DEFAULT_COMPOSE);
  gunichar unichar;
  gchar *q = NULL;

  if (normalized == NULL)
    return NULL;

  initials = g_string_new ("");

  unichar = g_utf8_get_char (normalized);
  g_string_append_unichar (initials, unichar);

  q = g_utf8_strrchr (normalized, -1, ' ');
  if (q != NULL && g_utf8_next_char (q) != NULL) {
    q = g_utf8_next_char (q);

    unichar = g_utf8_get_char (q);
    g_string_append_unichar (initials, unichar);
  }

  return g_string_free (initials, FALSE);
}

static GdkPixbuf *
update_custom_image (GdkPixbuf *pixbuf_from_icon,
                     GdkPixbuf *round_image,
                     gint       new_size)
{
  if (round_image &&
      gdk_pixbuf_get_width (round_image) == new_size &&
      !is_scaled (round_image))
    return g_object_ref (round_image);

  if (pixbuf_from_icon) {
    gint pixbuf_from_icon_size = MIN (gdk_pixbuf_get_width (pixbuf_from_icon),
                                      gdk_pixbuf_get_height (pixbuf_from_icon));
    if (pixbuf_from_icon_size == new_size)
      return make_round_image (pixbuf_from_icon, new_size);
  }

  if (round_image) {
    /* Use a scaled image till we get the new image from async loading */
    GdkPixbuf *pixbuf = gdk_pixbuf_scale_simple (round_image,
                                                 new_size,
                                                 new_size,
                                                 GDK_INTERP_BILINEAR);
    g_object_set_data (G_OBJECT (pixbuf), "scaled", GINT_TO_POINTER (TRUE));

    return pixbuf;
  }

  return NULL;
}

static void
size_prepared_cb (GdkPixbufLoader *loader,
                  gint             width,
                  gint             height,
                  gpointer         user_data)
{
  gint size = GPOINTER_TO_INT (user_data);
  gdouble ratio = (gdouble) width / (gdouble) height;

  if (width < height) {
    width = size;
    height = size / ratio;
  } else {
    width = size * ratio;
    height = size;
  }

  gdk_pixbuf_loader_set_size (loader, width, height);
}

/* This function is copied from the gdk-pixbuf project,
 * from the file gdk-pixbuf/gdk-pixbuf/gdk-pixbuf-io.c.
 * It was modified to fit libhandy's code style.
 */
static void
load_from_stream_async_cb (GObject      *stream,
                           GAsyncResult *res,
                           gpointer      data)
{
  g_autoptr (GTask) task = data;
  GdkPixbufLoader *loader = g_task_get_task_data (task);
  g_autoptr (GBytes) bytes = NULL;
  GError *error = NULL;

  bytes = g_input_stream_read_bytes_finish (G_INPUT_STREAM (stream), res, &error);
  if (bytes == NULL) {
    gdk_pixbuf_loader_close (loader, NULL);
    g_task_return_error (task, error);

    return;
  }

  if (g_bytes_get_size (bytes) == 0) {
    if (!gdk_pixbuf_loader_close (loader, &error)) {
      g_task_return_error (task, error);

      return;
    }

    g_task_return_pointer (task,
                           g_object_ref (gdk_pixbuf_loader_get_pixbuf (loader)),
                           g_object_unref);

    return;
  }

  if (!gdk_pixbuf_loader_write (loader,
                                g_bytes_get_data (bytes, NULL),
                                g_bytes_get_size (bytes),
                                &error)) {
    gdk_pixbuf_loader_close (loader, NULL);
    g_task_return_error (task, error);

    return;
  }

  g_input_stream_read_bytes_async (G_INPUT_STREAM (stream),
                                   LOAD_BUFFER_SIZE,
                                   G_PRIORITY_DEFAULT,
                                   g_task_get_cancellable (task),
                                   load_from_stream_async_cb,
                                   g_object_ref (task));
}

static void
icon_load_async_cb (GLoadableIcon *icon,
                    GAsyncResult  *res,
                    GTask         *task)
{
  GdkPixbufLoader *loader = g_task_get_task_data (task);
  g_autoptr (GInputStream) stream = NULL;
  g_autoptr (GError) error = NULL;

  stream = g_loadable_icon_load_finish (icon, res, NULL, &error);
  if (stream == NULL) {
    gdk_pixbuf_loader_close (loader, NULL);
    g_task_return_error (task, g_steal_pointer (&error));
    g_object_unref (task);

    return;
  }

  g_input_stream_read_bytes_async (stream,
                                   LOAD_BUFFER_SIZE,
                                   G_PRIORITY_DEFAULT,
                                   g_task_get_cancellable (task),
                                   load_from_stream_async_cb,
                                   task);
}

static GdkPixbuf *
load_from_gicon_async_finish (GAsyncResult  *async_result,
                              GError       **error)
{
  GTask *task = G_TASK (async_result);

  return g_task_propagate_pointer (task, error);
}

static void
load_from_gicon_async_for_display_cb (HdyAvatar    *self,
                                      GAsyncResult *res,
                                      gpointer     *user_data)
{
  g_autoptr (GError) error = NULL;
  g_autoptr (GdkPixbuf) pixbuf = NULL;

  pixbuf = load_from_gicon_async_finish (res, &error);

  if (error != NULL) {
    if (g_error_matches (error, HDY_AVATAR_ICON_ERROR, HDY_AVATAR_ICON_ERROR_EMPTY)) {
      self->loading_error = TRUE;
    } else if (!g_error_matches (error, G_IO_ERROR, G_IO_ERROR_CANCELLED)) {
      g_warning ("Failed to load icon: %s", error->message);
      self->loading_error = TRUE;
    }
  }

  self->currently_loading_size = -1;

  if (pixbuf) {
    g_autoptr (GdkPixbuf) custom_image = NULL;
    GtkStyleContext *context = gtk_widget_get_style_context (GTK_WIDGET (self));
    gint width = gtk_widget_get_allocated_width (GTK_WIDGET (self));
    gint height = gtk_widget_get_allocated_height (GTK_WIDGET (self));
    gint scale_factor = gtk_widget_get_scale_factor (GTK_WIDGET (self));
    gint new_size = MIN (width, height) * scale_factor;

    if (get_icon (self)) {
      custom_image = update_custom_image (pixbuf,
                                          NULL,
                                          new_size);

      if (!self->round_image && custom_image)
        gtk_style_context_add_class (context, "image");
    }

    g_set_object (&self->round_image, custom_image);
    gtk_widget_queue_draw (GTK_WIDGET (self));
  }
}

static void
load_from_gicon_async_for_export_cb (HdyAvatar    *self,
                                     GAsyncResult *res,
                                     gpointer     *user_data)
{
  GTask *task = G_TASK (user_data);
  g_autoptr (GError) error = NULL;
  g_autoptr (GdkPixbuf) pixbuf = NULL;

  pixbuf = load_from_gicon_async_finish (res, &error);

  if (!g_error_matches (error, HDY_AVATAR_ICON_ERROR, HDY_AVATAR_ICON_ERROR_EMPTY) &&
      !g_error_matches (error, G_IO_ERROR, G_IO_ERROR_CANCELLED)) {
    g_warning ("Failed to load icon: %s", error->message);
  }

  g_task_return_pointer (task,
                         g_steal_pointer (&pixbuf),
                         g_object_unref);
  g_object_unref (task);
}

static void
load_icon_async (HdyAvatar           *self,
                 gint                 size,
                 GCancellable        *cancellable,
                 GAsyncReadyCallback  callback,
                 gpointer             user_data)
{
  GTask *task = g_task_new (self, cancellable, callback, user_data);
  GdkPixbufLoader *loader = gdk_pixbuf_loader_new ();

  g_signal_connect (loader, "size-prepared",
                    G_CALLBACK (size_prepared_cb),
                    GINT_TO_POINTER (size));

  g_task_set_task_data (task, loader, g_object_unref);

  g_loadable_icon_load_async (get_icon (self),
                              size,
                              cancellable,
                              (GAsyncReadyCallback) icon_load_async_cb,
                              task);
}

/* This function is copied from the gdk-pixbuf project,
 * from the file gdk-pixbuf/gdk-pixbuf/gdk-pixbuf-io.c.
 * It was modified to fit libhandy's code style.
 */
static GdkPixbuf *
load_from_stream (GdkPixbufLoader  *loader,
                  GInputStream     *stream,
                  GCancellable     *cancellable,
                  GError          **error)
{
  GdkPixbuf *pixbuf;
  guchar buffer[LOAD_BUFFER_SIZE];

  while (TRUE) {
    gssize n_read = g_input_stream_read (stream, buffer, sizeof (buffer),
                                         cancellable, error);

    if (n_read < 0) {
      gdk_pixbuf_loader_close (loader, NULL);

      return NULL;
    }

    if (n_read == 0)
      break;

    if (!gdk_pixbuf_loader_write (loader, buffer, n_read, error)) {
      gdk_pixbuf_loader_close (loader, NULL);

      return NULL;
    }
  }

  if (!gdk_pixbuf_loader_close (loader, error))
    return NULL;

  pixbuf = gdk_pixbuf_loader_get_pixbuf (loader);
  if (pixbuf == NULL)
    return NULL;

  return g_object_ref (pixbuf);
}

static GdkPixbuf *
load_icon_sync (GLoadableIcon *icon,
                gint           size)
{
  g_autoptr (GError) error = NULL;
  g_autoptr (GInputStream) stream = g_loadable_icon_load (icon, size, NULL, NULL, &error);
  g_autoptr (GdkPixbufLoader) loader = gdk_pixbuf_loader_new ();
  g_autoptr (GdkPixbuf) pixbuf = NULL;

  if (error) {
    g_warning ("Failed to load icon: %s", error->message);
    return NULL;
  }

  g_signal_connect (loader, "size-prepared",
                    G_CALLBACK (size_prepared_cb),
                    GINT_TO_POINTER (size));

  pixbuf = load_from_stream (loader, stream, NULL, &error);

  if (error) {
    g_warning ("Failed to load pixbuf from GLoadableIcon: %s", error->message);
    return NULL;
  }

  return g_steal_pointer (&pixbuf);
}

static void
set_class_color (HdyAvatar *self)
{
  GtkStyleContext *context = gtk_widget_get_style_context (GTK_WIDGET (self));
  g_autofree GRand *rand = NULL;
  g_autofree gchar *new_class = NULL;
  g_autofree gchar *old_class = g_strdup_printf ("color%d", self->color_class);

  gtk_style_context_remove_class (context, old_class);

  if (self->text == NULL || strlen (self->text) == 0) {
    /* Use a random color if we don't have a text */
    rand = g_rand_new ();
    self->color_class = g_rand_int_range (rand, 1, NUMBER_OF_COLORS);
  } else {
    self->color_class = (g_str_hash (self->text) % NUMBER_OF_COLORS) + 1;
  }

  new_class = g_strdup_printf ("color%d", self->color_class);
  gtk_style_context_add_class (context, new_class);
}

static void
set_class_contrasted (HdyAvatar *self,
                      gint       size)
{
  GtkStyleContext *context = gtk_widget_get_style_context (GTK_WIDGET (self));

  if (size < 25)
    gtk_style_context_add_class (context, "contrasted");
  else
    gtk_style_context_remove_class (context, "contrasted");
}

static void
clear_pango_layout (HdyAvatar *self)
{
  g_clear_object (&self->layout);
}

static void
ensure_pango_layout (HdyAvatar *self)
{
  g_autofree gchar *initials = NULL;

  if (self->layout != NULL || self->text == NULL || strlen (self->text) == 0)
    return;

  initials = extract_initials_from_text (self->text);
  self->layout = gtk_widget_create_pango_layout (GTK_WIDGET (self), initials);
}

static void
set_font_size (HdyAvatar *self,
               gint       size)
{
  GtkStyleContext *context;
  PangoFontDescription *font_desc;
  gint width, height;
  gdouble padding;
  gdouble sqr_size;
  gdouble max_size;
  gdouble new_font_size;

  if (self->round_image != NULL || self->layout == NULL)
    return;

  context = gtk_widget_get_style_context (GTK_WIDGET (self));
  gtk_style_context_get (context, gtk_style_context_get_state (context),
                         "font", &font_desc, NULL);

  pango_layout_set_font_description (self->layout, font_desc);
  pango_layout_get_pixel_size (self->layout, &width, &height);

  /* This is the size of the biggest square fitting inside the circle */
  sqr_size = (gdouble)size / 1.4142;
  /* The padding has to be a function of the overall size.
   * The 0.4 is how steep the linear function grows and the -5 is just
   * an adjustment for smaller sizes which doesn't have a big impact on bigger sizes.
   * Make also sure we don't have a negative padding */
  padding = MAX (size * 0.4 - 5, 0);
  max_size = sqr_size - padding;
  new_font_size = (gdouble)height * (max_size / (gdouble)width);

  font_desc = pango_font_description_copy (font_desc);
  pango_font_description_set_absolute_size (font_desc,
                                            CLAMP (new_font_size, 0, max_size) * PANGO_SCALE);
  pango_layout_set_font_description (self->layout, font_desc);
  pango_font_description_free (font_desc);
}

static void
hdy_avatar_get_property (GObject    *object,
                         guint       property_id,
                         GValue     *value,
                         GParamSpec *pspec)
{
  HdyAvatar *self = HDY_AVATAR (object);

  switch (property_id) {
  case PROP_ICON_NAME:
    g_value_set_string (value, hdy_avatar_get_icon_name (self));
    break;

  case PROP_TEXT:
    g_value_set_string (value, hdy_avatar_get_text (self));
    break;

  case PROP_SHOW_INITIALS:
    g_value_set_boolean (value, hdy_avatar_get_show_initials (self));
    break;

  case PROP_SIZE:
    g_value_set_int (value, hdy_avatar_get_size (self));
    break;

  case PROP_LOADABLE_ICON:
    g_value_set_object (value, hdy_avatar_get_loadable_icon (self));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
    break;
  }
}

static void
hdy_avatar_set_property (GObject      *object,
                         guint         property_id,
                         const GValue *value,
                         GParamSpec   *pspec)
{
  HdyAvatar *self = HDY_AVATAR (object);

  switch (property_id) {
  case PROP_ICON_NAME:
    hdy_avatar_set_icon_name (self, g_value_get_string (value));
    break;

  case PROP_TEXT:
    hdy_avatar_set_text (self, g_value_get_string (value));
    break;

  case PROP_SHOW_INITIALS:
    hdy_avatar_set_show_initials (self, g_value_get_boolean (value));
    break;

  case PROP_SIZE:
    hdy_avatar_set_size (self, g_value_get_int (value));
    break;

  case PROP_LOADABLE_ICON:
    hdy_avatar_set_loadable_icon (self, g_value_get_object (value));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
    break;
  }
}

static void
hdy_avatar_dispose (GObject *object)
{
  HdyAvatar *self = HDY_AVATAR (object);

  g_cancellable_cancel (self->cancellable);
  g_clear_object (&self->icon);
  g_clear_object (&self->load_func_icon);

  G_OBJECT_CLASS (hdy_avatar_parent_class)->dispose (object);
}

static void
hdy_avatar_finalize (GObject *object)
{
  HdyAvatar *self = HDY_AVATAR (object);

  g_clear_pointer (&self->icon_name, g_free);
  g_clear_pointer (&self->text, g_free);
  g_clear_object (&self->round_image);
  g_clear_object (&self->layout);
  g_clear_object (&self->cancellable);

  G_OBJECT_CLASS (hdy_avatar_parent_class)->finalize (object);
}

static void
draw_for_size (HdyAvatar *self,
               cairo_t   *cr,
               GdkPixbuf *custom_image,
               gint       width,
               gint       height,
               gint       scale_factor)
{
  GtkStyleContext *context = gtk_widget_get_style_context (GTK_WIDGET (self));
  gint size = MIN (width, height);
  gdouble x = (gdouble)(width - size) / 2.0;
  gdouble y = (gdouble)(height - size) / 2.0;
  const gchar *icon_name;
  GdkRGBA color;
  g_autoptr (GtkIconInfo) icon = NULL;
  g_autoptr (GdkPixbuf) pixbuf = NULL;
  g_autoptr (GError) error = NULL;
  g_autoptr (cairo_surface_t) surface = NULL;

  set_class_contrasted (self, size);

  if (custom_image) {
    surface = gdk_cairo_surface_create_from_pixbuf (custom_image, scale_factor,
                                                    gtk_widget_get_window (GTK_WIDGET (self)));
    gtk_render_icon_surface (context, cr, surface, x, y);
    gtk_render_background (context, cr, x, y, size, size);
    gtk_render_frame (context, cr, x, y, size, size);
    return;
  }

  gtk_render_background (context, cr, x, y, size, size);
  gtk_render_frame (context, cr, x, y, size, size);

  ensure_pango_layout (self);

  if (self->show_initials && self->layout != NULL) {
    set_font_size (self, size);
    pango_layout_get_pixel_size (self->layout, &width, &height);

    gtk_render_layout (context, cr,
                       ((gdouble) (size - width) / 2.0) + x,
                       ((gdouble) (size - height) / 2.0) + y,
                       self->layout);
    return;
  }

  icon_name = self->icon_name && *self->icon_name != '\0' ?
    self->icon_name : "avatar-default-symbolic";
  icon = gtk_icon_theme_lookup_icon_for_scale (gtk_icon_theme_get_default (),
                                     icon_name,
                                     size / 2, scale_factor,
                                     GTK_ICON_LOOKUP_FORCE_SYMBOLIC);
  if (icon == NULL) {
    g_critical ("Failed to load icon `%s'", icon_name);
    return;
  }

  gtk_style_context_get_color (context, gtk_style_context_get_state (context), &color);
  pixbuf = gtk_icon_info_load_symbolic (icon, &color, NULL, NULL, NULL, NULL, &error);
  if (error != NULL) {
    g_critical ("Failed to load icon `%s': %s", icon_name, error->message);
    return;
  }

  surface = gdk_cairo_surface_create_from_pixbuf (pixbuf, scale_factor,
                                                  gtk_widget_get_window (GTK_WIDGET (self)));

  width = cairo_image_surface_get_width (surface);
  height = cairo_image_surface_get_height (surface);
  gtk_render_icon_surface (context, cr, surface,
                           (((gdouble) size - ((gdouble) width / (gdouble) scale_factor)) / 2.0) + x,
                           (((gdouble) size - ((gdouble) height / (gdouble) scale_factor)) / 2.0) + y);
}

static gboolean
hdy_avatar_draw (GtkWidget *widget,
                 cairo_t   *cr)
{
  HdyAvatar *self = HDY_AVATAR (widget);
  GdkPixbuf *custom_image = NULL;
  GtkStyleContext *context = gtk_widget_get_style_context (widget);
  gint width = gtk_widget_get_allocated_width (widget);
  gint height = gtk_widget_get_allocated_height (widget);
  gint scale_factor = gtk_widget_get_scale_factor (widget);
  gint new_size = MIN (width, height) * scale_factor;

  if (get_icon (self)) {
    custom_image = update_custom_image (NULL, self->round_image, new_size);

    if ((!custom_image &&
        !self->loading_error) ||
        (self->currently_loading_size != new_size &&
        is_scaled (custom_image))) {
      self->currently_loading_size = new_size;
      g_cancellable_cancel (self->cancellable);
      g_set_object (&self->cancellable, g_cancellable_new ());
      load_icon_async (self,
                       new_size,
                       self->cancellable,
                       (GAsyncReadyCallback) load_from_gicon_async_for_display_cb,
                       NULL);
    }

    /* We don't want to draw a broken custom image, because it may be scaled
       and we prefer to use the generated one in this case */
    if (self->loading_error)
      g_clear_object (&custom_image);
  }

  if (self->round_image && !custom_image)
    gtk_style_context_remove_class (context, "image");

  if (!self->round_image && custom_image)
    gtk_style_context_add_class (context, "image");

  g_set_object (&self->round_image, custom_image);
  draw_for_size (self, cr, self->round_image, width, height, scale_factor);

  return FALSE;
}

/* This private method is prefixed by the class name because it will be a
 * virtual method in GTK 4.
 */
static void
hdy_avatar_measure (GtkWidget      *widget,
                    GtkOrientation  orientation,
                    gint            for_size,
                    gint           *minimum,
                    gint           *natural,
                    gint           *minimum_baseline,
                    gint           *natural_baseline)
{
  HdyAvatar *self = HDY_AVATAR (widget);

  if (minimum)
    *minimum = self->size;
  if (natural)
    *natural = self->size;

  hdy_css_measure (widget, orientation, minimum, natural);
}

static void
hdy_avatar_get_preferred_width (GtkWidget *widget,
                                gint      *minimum,
                                gint      *natural)
{
  hdy_avatar_measure (widget, GTK_ORIENTATION_HORIZONTAL, -1,
                      minimum, natural, NULL, NULL);
}

static void
hdy_avatar_get_preferred_width_for_height (GtkWidget *widget,
                                           gint       height,
                                           gint      *minimum,
                                           gint      *natural)
{
  hdy_avatar_measure (widget, GTK_ORIENTATION_HORIZONTAL, height,
                      minimum, natural, NULL, NULL);
}

static void
hdy_avatar_get_preferred_height (GtkWidget *widget,
                                 gint      *minimum,
                                 gint      *natural)
{
  hdy_avatar_measure (widget, GTK_ORIENTATION_VERTICAL, -1,
                      minimum, natural, NULL, NULL);
}

static void
hdy_avatar_get_preferred_height_for_width (GtkWidget *widget,
                                           gint       width,
                                           gint      *minimum,
                                           gint      *natural)
{
  hdy_avatar_measure (widget, GTK_ORIENTATION_VERTICAL, width,
                      minimum, natural, NULL, NULL);
}

static GtkSizeRequestMode
hdy_avatar_get_request_mode (GtkWidget *widget)
{
  return GTK_SIZE_REQUEST_HEIGHT_FOR_WIDTH;
}

static void
hdy_avatar_size_allocate (GtkWidget     *widget,
                          GtkAllocation *allocation)
{
  GtkAllocation clip;

  hdy_css_size_allocate_self (widget, allocation);
  gtk_widget_set_allocation (widget, allocation);

  gtk_render_background_get_clip (gtk_widget_get_style_context (widget),
                                  allocation->x,
                                  allocation->y,
                                  allocation->width,
                                  allocation->height,
                                  &clip);

  GTK_WIDGET_CLASS (hdy_avatar_parent_class)->size_allocate (widget, allocation);
  gtk_widget_set_clip (widget, &clip);
}

static void
hdy_avatar_class_init (HdyAvatarClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);

  object_class->dispose = hdy_avatar_dispose;
  object_class->finalize = hdy_avatar_finalize;
  object_class->set_property = hdy_avatar_set_property;
  object_class->get_property = hdy_avatar_get_property;

  widget_class->draw = hdy_avatar_draw;
  widget_class->get_request_mode = hdy_avatar_get_request_mode;
  widget_class->get_preferred_width = hdy_avatar_get_preferred_width;
  widget_class->get_preferred_height = hdy_avatar_get_preferred_height;
  widget_class->get_preferred_width_for_height = hdy_avatar_get_preferred_width_for_height;
  widget_class->get_preferred_height_for_width = hdy_avatar_get_preferred_height_for_width;
  widget_class->size_allocate = hdy_avatar_size_allocate;

  /**
   * HdyAvatar:size:
   *
   * The avatar size of the avatar.
   */
  props[PROP_SIZE] =
    g_param_spec_int ("size",
                      "Size",
                      "The size of the avatar",
                      -1, INT_MAX, -1,
                      G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyAvatar:icon-name:
   *
   * The name of the icon in the icon theme to use when the icon should be
   * displayed.
   * If no name is set, the avatar-default-symbolic icon will be used.
   * If the name doesn't match a valid icon, it is an error and no icon will be
   * displayed.
   * If the icon theme is changed, the image will be updated automatically.
   *
   * Since: 1.0
   */
  props[PROP_ICON_NAME] =
    g_param_spec_string ("icon-name",
                         "Icon name",
                         "The name of the icon from the icon theme",
                         NULL,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyAvatar:text:
   *
   * The text used for the initials and for generating the color.
   * If #HdyAvatar:show-initials is %FALSE it's only used to generate the color.
   */
  props[PROP_TEXT] =
    g_param_spec_string ("text",
                         "Text",
                         "The text used to generate the color and the initials",
                         NULL,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyAvatar:show_initials:
   *
   * Whether to show the initials or the fallback icon on the generated avatar.
   */
  props[PROP_SHOW_INITIALS] =
    g_param_spec_boolean ("show-initials",
                          "Show initials",
                          "Whether to show the initials",
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyAvatar:loadable-icon:
   *
   * A #GLoadableIcon used to load the avatar.
   *
   * Since: 1.2
   */
  props[PROP_LOADABLE_ICON] =
    g_param_spec_object ("loadable-icon",
                         "Loadable Icon",
                         "The loadable icon used to load the avatar",
                         G_TYPE_LOADABLE_ICON,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  g_object_class_install_properties (object_class, PROP_LAST_PROP, props);

  gtk_widget_class_set_css_name (widget_class, "avatar");
}

static void
hdy_avatar_init (HdyAvatar *self)
{
  set_class_color (self);
  g_signal_connect (self, "screen-changed", G_CALLBACK (clear_pango_layout), NULL);
}

/**
 * hdy_avatar_new:
 * @size: The size of the avatar
 * @text: (nullable): The text used to generate the color and initials if
 * @show_initials is %TRUE. The color is selected at random if @text is empty.
 * @show_initials: whether to show the initials or the fallback icon on
 * top of the color generated based on @text.
 *
 * Creates a new #HdyAvatar.
 *
 * Returns: the newly created #HdyAvatar
 */
GtkWidget *
hdy_avatar_new (gint         size,
                const gchar *text,
                gboolean     show_initials)
{
  return g_object_new (HDY_TYPE_AVATAR,
                       "size", size,
                       "text", text,
                       "show-initials", show_initials,
                       NULL);
}

/**
 * hdy_avatar_get_icon_name:
 * @self: a #HdyAvatar
 *
 * Gets the name of the icon in the icon theme to use when the icon should be
 * displayed.
 *
 * Returns: (nullable) (transfer none): the name of the icon from the icon theme.
 *
 * Since: 1.0
 */
const gchar *
hdy_avatar_get_icon_name (HdyAvatar *self)
{
  g_return_val_if_fail (HDY_IS_AVATAR (self), NULL);

  return self->icon_name;
}

/**
 * hdy_avatar_set_icon_name:
 * @self: a #HdyAvatar
 * @icon_name: (nullable): the name of the icon from the icon theme
 *
 * Sets the name of the icon in the icon theme to use when the icon should be
 * displayed.
 * If no name is set, the avatar-default-symbolic icon will be used.
 * If the name doesn't match a valid icon, it is an error and no icon will be
 * displayed.
 * If the icon theme is changed, the image will be updated automatically.
 *
 * Since: 1.0
 */
void
hdy_avatar_set_icon_name (HdyAvatar   *self,
                          const gchar *icon_name)
{
  g_return_if_fail (HDY_IS_AVATAR (self));

  if (g_strcmp0 (self->icon_name, icon_name) == 0)
    return;

  g_clear_pointer (&self->icon_name, g_free);
  self->icon_name = g_strdup (icon_name);

  if (!self->round_image &&
      (!self->show_initials || self->layout == NULL))
    gtk_widget_queue_draw (GTK_WIDGET (self));

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_ICON_NAME]);
}

/**
 * hdy_avatar_get_text:
 * @self: a #HdyAvatar
 *
 * Get the text used to generate the fallback initials and color
 *
 * Returns: (nullable) (transfer none): returns the text used to generate
 * the fallback initials. This is the internal string used by
 * the #HdyAvatar, and must not be modified.
 */
const gchar *
hdy_avatar_get_text (HdyAvatar *self)
{
  g_return_val_if_fail (HDY_IS_AVATAR (self), NULL);

  return self->text;
}

/**
 * hdy_avatar_set_text:
 * @self: a #HdyAvatar
 * @text: (nullable): the text used to get the initials and color
 *
 * Set the text used to generate the fallback initials color
 */
void
hdy_avatar_set_text (HdyAvatar   *self,
                     const gchar *text)
{
  g_return_if_fail (HDY_IS_AVATAR (self));

  if (g_strcmp0 (self->text, text) == 0)
    return;

  g_clear_pointer (&self->text, g_free);
  self->text = g_strdup (text);

  clear_pango_layout (self);
  set_class_color (self);
  gtk_widget_queue_draw (GTK_WIDGET (self));

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_TEXT]);
}

/**
 * hdy_avatar_get_show_initials:
 * @self: a #HdyAvatar
 *
 * Returns whether initials are used for the fallback or the icon.
 *
 * Returns: %TRUE if the initials are used for the fallback.
 */
gboolean
hdy_avatar_get_show_initials (HdyAvatar *self)
{
  g_return_val_if_fail (HDY_IS_AVATAR (self), FALSE);

  return self->show_initials;
}

/**
 * hdy_avatar_set_show_initials:
 * @self: a #HdyAvatar
 * @show_initials: whether the initials should be shown on the fallback avatar
 * or the icon.
 *
 * Sets whether the initials should be shown on the fallback avatar or the icon.
 */
void
hdy_avatar_set_show_initials (HdyAvatar *self,
                              gboolean   show_initials)
{
  g_return_if_fail (HDY_IS_AVATAR (self));

  if (self->show_initials == show_initials)
    return;

  self->show_initials = show_initials;

  gtk_widget_queue_draw (GTK_WIDGET (self));
  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_SHOW_INITIALS]);
}

/**
 * hdy_avatar_set_image_load_func:
 * @self: a #HdyAvatar
 * @load_image: (closure user_data) (nullable): callback to set a custom image
 * @user_data: (nullable): user data passed to @load_image
 * @destroy: (nullable): destroy notifier for @user_data
 *
 * A callback which is called when the custom image need to be reloaded for some
 * reason (e.g. scale-factor changes).
 *
 * Deprecated: 1.2: use hdy_avatar_set_loadable_icon() instead.
 */
void
hdy_avatar_set_image_load_func (HdyAvatar              *self,
                                HdyAvatarImageLoadFunc  load_image,
                                gpointer                user_data,
                                GDestroyNotify          destroy)
{
  g_autoptr (HdyAvatarIcon) icon = NULL;

  g_return_if_fail (HDY_IS_AVATAR (self));
  g_return_if_fail (user_data != NULL || (user_data == NULL && destroy == NULL));

  if (load_image != NULL)
    icon = hdy_avatar_icon_new (load_image, user_data, destroy);

  if (self->load_func_icon && !self->icon) {
    g_cancellable_cancel (self->cancellable);
    g_clear_object (&self->cancellable);
    self->currently_loading_size = -1;
    self->loading_error = FALSE;
  }

  g_set_object (&self->load_func_icon, icon);

  /* Don't update the custom avatar when we have a user set GLoadableIcon */
  if (self->icon)
    return;

  if (self->load_func_icon) {
    gint scale_factor = gtk_widget_get_scale_factor (GTK_WIDGET (self));

    self->cancellable = g_cancellable_new ();
    self->currently_loading_size = self->size * scale_factor;
    load_icon_async (self,
                     self->currently_loading_size,
                     self->cancellable,
                     (GAsyncReadyCallback) load_from_gicon_async_for_display_cb,
                     NULL);
  } else {
    gtk_widget_queue_draw (GTK_WIDGET (self));
  }
}

/**
 * hdy_avatar_get_size:
 * @self: a #HdyAvatar
 *
 * Returns the size of the avatar.
 *
 * Returns: the size of the avatar.
 */
gint
hdy_avatar_get_size (HdyAvatar *self)
{
  g_return_val_if_fail (HDY_IS_AVATAR (self), 0);

  return self->size;
}

/**
 * hdy_avatar_set_size:
 * @self: a #HdyAvatar
 * @size: The size to be used for the avatar
 *
 * Sets the size of the avatar.
 */
void
hdy_avatar_set_size (HdyAvatar *self,
                     gint       size)
{
  g_return_if_fail (HDY_IS_AVATAR (self));
  g_return_if_fail (size >= -1);

  if (self->size == size)
    return;

  self->size = size;

  gtk_widget_queue_resize (GTK_WIDGET (self));
  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_SIZE]);
}

/**
 * hdy_avatar_draw_to_pixbuf:
 * @self: a #HdyAvatar
 * @size: The size of the pixbuf
 * @scale_factor: The scale factor
 *
 * Renders @self into a pixbuf at @size and @scale_factor. This can be used to export the fallback avatar.
 *
 * Returns: (transfer full): the pixbuf.
 *
 * Since: 1.2
 */
GdkPixbuf *
hdy_avatar_draw_to_pixbuf (HdyAvatar *self,
                           gint       size,
                           gint       scale_factor)
{
  g_autoptr (cairo_surface_t) surface = NULL;
  g_autoptr (cairo_t) cr = NULL;
  g_autoptr (GdkPixbuf) custom_image = NULL;
  g_autoptr (GdkPixbuf) pixbuf_from_icon = NULL;
  gint scaled_size = size * scale_factor;
  GtkStyleContext *context;
  GtkAllocation bounds;

  g_return_val_if_fail (HDY_IS_AVATAR (self), NULL);
  g_return_val_if_fail (size > 0, NULL);
  g_return_val_if_fail (scale_factor > 0, NULL);

  context = gtk_widget_get_style_context (GTK_WIDGET (self));
  gtk_render_background_get_clip (context, 0, 0, size, size, &bounds);

  surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32,
                                        bounds.width * scale_factor,
                                        bounds.height * scale_factor);
  cairo_surface_set_device_scale (surface, scale_factor, scale_factor);
  cr = cairo_create (surface);

  cairo_translate (cr, -bounds.x, -bounds.y);

  if (get_icon (self)) {
    /* Only used the cached round_image if it fits the size and it isn't scaled*/
    if (!self->round_image ||
        is_scaled (self->round_image) ||
        gdk_pixbuf_get_width (self->round_image) != scaled_size) {
      pixbuf_from_icon = load_icon_sync (get_icon (self), scaled_size);
      custom_image = update_custom_image (pixbuf_from_icon, NULL, scaled_size);
    } else {
      custom_image = update_custom_image (NULL, self->round_image, scaled_size);
    }
  }

  draw_for_size (self, cr, custom_image, size, size, scale_factor);

  return gdk_pixbuf_get_from_surface (surface, 0, 0,
                                      bounds.width * scale_factor,
                                      bounds.height * scale_factor);
}

/**
 * hdy_avatar_draw_to_pixbuf_async:
 * @self: a #HdyAvatar
 * @size: The size of the pixbuf
 * @scale_factor: The scale factor
 * @cancellable: (nullable): optional #GCancellable object, %NULL to ignore
 * @callback: (scope async): a #GAsyncReadyCallback to call when the avatar is generated
 * @user_data: (closure): the data to pass to callback function

 * Renders asynchronously @self into a pixbuf at @size and @scale_factor.
 * This can be used to export the fallback avatar.
 *
 * Since: 1.2
 */
void
hdy_avatar_draw_to_pixbuf_async (HdyAvatar           *self,
                                 gint                 size,
                                 gint                 scale_factor,
                                 GCancellable        *cancellable,
                                 GAsyncReadyCallback  callback,
                                 gpointer             user_data)
{
  g_autoptr (GTask) task = NULL;
  gint scaled_size = size * scale_factor;
  SizeData *data;

  g_return_if_fail (HDY_IS_AVATAR (self));
  g_return_if_fail (size > 0);
  g_return_if_fail (scale_factor > 0);

  data = g_slice_new (SizeData);
  data->size = size;
  data->scale_factor = scale_factor;

  task = g_task_new (self, cancellable, callback, user_data);
  g_task_set_source_tag (task, hdy_avatar_draw_to_pixbuf_async);
  g_task_set_task_data (task, data, (GDestroyNotify) size_data_free);

  if (get_icon (self) &&
      (!self->round_image ||
       gdk_pixbuf_get_width (self->round_image) != scaled_size ||
       is_scaled (self->round_image)))
    load_icon_async (self,
                     scaled_size,
                     cancellable,
                     (GAsyncReadyCallback) load_from_gicon_async_for_export_cb,
                     g_steal_pointer (&task));
  else
    g_task_return_pointer (task, NULL, NULL);
}

/**
 * hdy_avatar_draw_to_pixbuf_finish:
 * @self: a #HdyAvatar
 * @async_result: a #GAsyncResult
 *
 * Finishes an asynchronous draw of an avatar to a pixbuf.
 *
 * Returns: (transfer full): a #GdkPixbuf
 *
 * Since: 1.2
 */
GdkPixbuf *
hdy_avatar_draw_to_pixbuf_finish (HdyAvatar    *self,
                                  GAsyncResult *async_result)
{
  GTask *task;
  g_autoptr (GdkPixbuf) pixbuf_from_icon = NULL;
  g_autoptr (GdkPixbuf) custom_image = NULL;
  g_autoptr (cairo_surface_t) surface = NULL;
  g_autoptr (cairo_t) cr = NULL;
  SizeData *data;
  GtkStyleContext *context;
  GtkAllocation bounds;

  g_return_val_if_fail (G_IS_TASK (async_result), NULL);

  task = G_TASK (async_result);

  g_warn_if_fail (g_task_get_source_tag (task) == hdy_avatar_draw_to_pixbuf_async);

  data = g_task_get_task_data (task);

  context = gtk_widget_get_style_context (GTK_WIDGET (self));
  gtk_render_background_get_clip (context, 0, 0, data->size, data->size, &bounds);

  surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32,
                                        bounds.width * data->scale_factor,
                                        bounds.height * data->scale_factor);
  cairo_surface_set_device_scale (surface, data->scale_factor, data->scale_factor);
  cr = cairo_create (surface);

  cairo_translate (cr, -bounds.x, -bounds.y);

  pixbuf_from_icon = g_task_propagate_pointer (task, NULL);
  custom_image = update_custom_image (pixbuf_from_icon,
                                      NULL,
                                      data->size * data->scale_factor);
  draw_for_size (self, cr, custom_image, data->size, data->size, data->scale_factor);

  return gdk_pixbuf_get_from_surface (surface, 0, 0,
                                      bounds.width * data->scale_factor,
                                      bounds.height * data->scale_factor);
}

/**
 * hdy_avatar_get_loadable_icon:
 * @self: a #HdyAvatar
 *
 * Gets the #GLoadableIcon set via hdy_avatar_set_loadable_icon().
 *
 * Returns: (nullable) (transfer none): the #GLoadableIcon
 *
 * Since: 1.2
 */
GLoadableIcon *
hdy_avatar_get_loadable_icon (HdyAvatar *self)
{
  g_return_val_if_fail (HDY_IS_AVATAR (self), NULL);

  return self->icon;
}

/**
 * hdy_avatar_set_loadable_icon:
 * @self: a #HdyAvatar
 * @icon: (nullable): a #GLoadableIcon
 *
 * Sets the #GLoadableIcon to use as an avatar.
 * The previous avatar is displayed till the new avatar is loaded,
 * to immediately remove the custom avatar set the loadable-icon to %NULL.
 *
 * The #GLoadableIcon set via this function is prefered over a set #HdyAvatarImageLoadFunc.
 *
 * Since: 1.2
 */
void
hdy_avatar_set_loadable_icon (HdyAvatar     *self,
                              GLoadableIcon *icon)
{
  g_return_if_fail (HDY_IS_AVATAR (self));
  g_return_if_fail (icon == NULL || G_IS_LOADABLE_ICON (icon));

  if (icon == self->icon)
    return;

  if (self->icon) {
    g_cancellable_cancel (self->cancellable);
    g_clear_object (&self->cancellable);
    self->currently_loading_size = -1;
    self->loading_error = FALSE;
  }

  g_set_object (&self->icon, icon);

  if (self->icon) {
    gint scale_factor = gtk_widget_get_scale_factor (GTK_WIDGET (self));
    self->currently_loading_size = self->size * scale_factor;
    load_icon_async (self,
                     self->currently_loading_size,
                     self->cancellable,
                     (GAsyncReadyCallback) load_from_gicon_async_for_display_cb,
                     NULL);
  } else {
    gtk_widget_queue_draw (GTK_WIDGET (self));
  }

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_LOADABLE_ICON]);
}
