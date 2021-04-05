/*
 * Copyright (C) 2020-2021 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1+
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#include "config.h"
#include "hdy-tab-private.h"

#include <glib/gi18n-lib.h>

#include "hdy-animation-private.h"
#include "hdy-bidi-private.h"
#include "hdy-css-private.h"
#include "hdy-fading-label-private.h"

#define FADE_WIDTH 18
#define CLOSE_BTN_ANIMATION_DURATION 150

#define BASE_WIDTH 118
#define BASE_WIDTH_PINNED 28

struct _HdyTab
{
  GtkContainer parent_instance;

  GtkWidget *title;
  GtkWidget *icon_stack;
  GtkImage *icon;
  GtkSpinner *spinner;
  GtkImage *indicator_icon;
  GtkWidget *indicator_btn;
  GtkWidget *close_btn;

  GtkGesture *gesture;
  GdkWindow *window;

  HdyTabView *view;
  HdyTabPage *page;
  gboolean pinned;
  gboolean dragging;
  gint display_width;

  gboolean hovering;
  gboolean selected;
  gboolean inverted;
  gboolean title_inverted;
  gboolean close_overlap;
  gboolean show_close;
  gboolean fully_visible;

  HdyAnimation *close_btn_animation;
  cairo_pattern_t *gradient;
  gdouble gradient_opacity;

  GBinding *title_binding;
};

G_DEFINE_TYPE (HdyTab, hdy_tab, GTK_TYPE_CONTAINER)

enum {
  PROP_0,
  PROP_VIEW,
  PROP_PINNED,
  PROP_DRAGGING,
  PROP_PAGE,
  PROP_DISPLAY_WIDTH,
  PROP_HOVERING,
  PROP_INVERTED,
  LAST_PROP
};

static GParamSpec *props[LAST_PROP];

static inline void
set_style_class (GtkWidget   *widget,
                 const gchar *style_class,
                 gboolean     enabled)
{
  GtkStyleContext *context = gtk_widget_get_style_context (widget);

  if (enabled)
    gtk_style_context_add_class (context, style_class);
  else
    gtk_style_context_remove_class (context, style_class);
}

static void
close_btn_animation_value_cb (gdouble  value,
                              HdyTab  *self)
{
  gtk_widget_set_opacity (self->close_btn, value);
  gtk_widget_queue_draw (GTK_WIDGET (self));
}

static void
close_btn_animation_done_cb (HdyTab *self)
{
  if (!self->show_close)
    gtk_widget_set_child_visible (self->close_btn, FALSE);
  gtk_widget_set_opacity (self->close_btn, self->show_close ? 1 : 0);

  g_clear_pointer (&self->close_btn_animation, hdy_animation_unref);
}

static void
update_state (HdyTab *self)
{
  GtkStateFlags new_state;
  gboolean show_close;

  new_state = gtk_widget_get_state_flags (GTK_WIDGET (self)) &
    ~(GTK_STATE_FLAG_PRELIGHT | GTK_STATE_FLAG_CHECKED);

  if (self->hovering || self->dragging)
    new_state |= GTK_STATE_FLAG_PRELIGHT;

  if (self->selected || self->dragging)
    new_state |= GTK_STATE_FLAG_CHECKED;

  gtk_widget_set_state_flags (GTK_WIDGET (self), new_state, TRUE);

  show_close = (self->hovering && self->fully_visible) || self->selected || self->dragging;

  if (self->show_close != show_close) {
    gdouble opacity = gtk_widget_get_opacity (self->close_btn);

    if (self->close_btn_animation)
      hdy_animation_stop (self->close_btn_animation);

    self->show_close = show_close;

    /* gtk_widget_set_child_visible() does not no-op when it's already
     * visible, avoid extra work */
    if (show_close && !gtk_widget_get_child_visible (self->close_btn))
      gtk_widget_set_child_visible (self->close_btn, TRUE);

    self->close_btn_animation =
      hdy_animation_new (GTK_WIDGET (self),
                         opacity,
                         self->show_close ? 1 : 0,
                         CLOSE_BTN_ANIMATION_DURATION,
                         hdy_ease_in_out_cubic,
                         (HdyAnimationValueCallback) close_btn_animation_value_cb,
                         (HdyAnimationDoneCallback) close_btn_animation_done_cb,
                         self);

    hdy_animation_start (self->close_btn_animation);
  }
}

static void
update_tooltip (HdyTab *self)
{
  const gchar *tooltip = hdy_tab_page_get_tooltip (self->page);

  if (tooltip)
    gtk_widget_set_tooltip_markup (GTK_WIDGET (self), tooltip);
  else
    gtk_widget_set_tooltip_text (GTK_WIDGET (self),
                                 hdy_tab_page_get_title (self->page));
}

static void
update_title (HdyTab *self)
{
  const gchar *title = hdy_tab_page_get_title (self->page);
  PangoDirection title_direction = PANGO_DIRECTION_NEUTRAL;
  GtkTextDirection direction = gtk_widget_get_direction (GTK_WIDGET (self));
  gboolean title_inverted;

  if (title)
    title_direction = hdy_find_base_dir (title, -1);

  title_inverted =
    (title_direction == PANGO_DIRECTION_LTR && direction == GTK_TEXT_DIR_RTL) ||
    (title_direction == PANGO_DIRECTION_RTL && direction == GTK_TEXT_DIR_LTR);

  if (self->title_inverted != title_inverted) {
    self->title_inverted = title_inverted;
    gtk_widget_queue_allocate (GTK_WIDGET (self));
  }

  update_tooltip (self);
}

static void
update_spinner (HdyTab *self)
{
  gboolean loading = self->page && hdy_tab_page_get_loading (self->page);
  gboolean mapped = gtk_widget_get_mapped (GTK_WIDGET (self));

  /* Don't use CPU when not needed */
  if (loading && mapped)
    gtk_spinner_start (self->spinner);
  else
    gtk_spinner_stop (self->spinner);
}

static void
update_icons (HdyTab *self)
{
  GIcon *gicon = hdy_tab_page_get_icon (self->page);
  gboolean loading = hdy_tab_page_get_loading (self->page);
  GIcon *indicator = hdy_tab_page_get_indicator_icon (self->page);
  const gchar *name = loading ? "spinner" : "icon";

  if (self->pinned && !gicon)
    gicon = hdy_tab_view_get_default_icon (self->view);

  gtk_image_set_from_gicon (self->icon, gicon, GTK_ICON_SIZE_BUTTON);
  gtk_widget_set_visible (self->icon_stack,
                          (gicon != NULL || loading) &&
                          (!self->pinned || indicator == NULL));
  gtk_stack_set_visible_child_name (GTK_STACK (self->icon_stack), name);

  gtk_image_set_from_gicon (self->indicator_icon, indicator, GTK_ICON_SIZE_BUTTON);
  gtk_widget_set_visible (self->indicator_btn, indicator != NULL);
}

static void
update_indicator (HdyTab *self)
{
  gboolean activatable = self->page && hdy_tab_page_get_indicator_activatable (self->page);
  gboolean clickable = activatable && (self->selected || (!self->pinned && self->fully_visible));

  set_style_class (self->indicator_btn, "clickable", clickable);
}

static void
update_needs_attention (HdyTab *self)
{
  set_style_class (GTK_WIDGET (self), "needs-attention",
                   hdy_tab_page_get_needs_attention (self->page));
}

static void
update_loading (HdyTab *self)
{
  update_icons (self);
  update_spinner (self);
  set_style_class (GTK_WIDGET (self), "loading",
                   hdy_tab_page_get_loading (self->page));
}

static void
update_selected (HdyTab *self)
{
  self->selected = self->dragging;

  if (self->page)
    self->selected |= hdy_tab_page_get_selected (self->page);

  update_state (self);
  update_indicator (self);
}

static gboolean
close_idle_cb (HdyTab *self)
{
  hdy_tab_view_close_page (self->view, self->page);

  return G_SOURCE_REMOVE;
}

static void
close_clicked_cb (HdyTab *self)
{
  if (!self->page)
    return;

  /* When animations are disabled, we don't want to immediately remove the
   * whole tab mid-click. Instead, defer it until the click has happened.
   */
  g_idle_add ((GSourceFunc) close_idle_cb, self);
}

static void
indicator_clicked_cb (HdyTab *self)
{
  gboolean clickable;

  if (!self->page)
    return;

  clickable = hdy_tab_page_get_indicator_activatable (self->page) &&
              (self->selected || (!self->pinned && self->fully_visible));

  if (!clickable) {
    hdy_tab_view_set_selected_page (self->view, self->page);

    return;
  }

  g_signal_emit_by_name (self->view, "indicator-activated", self->page);
}

static void
ensure_gradient (HdyTab *self)
{
  gdouble opacity = gtk_widget_get_opacity (self->close_btn);

  if (self->gradient && self->gradient_opacity == opacity)
    return;

  g_clear_pointer (&self->gradient, cairo_pattern_destroy);

  self->gradient_opacity = opacity;
  self->gradient = cairo_pattern_create_linear (0, 0, FADE_WIDTH, 0);
  cairo_pattern_add_color_stop_rgba (self->gradient, 0, 1, 1, 1, 0);
  cairo_pattern_add_color_stop_rgba (self->gradient, 1, 1, 1, 1, opacity);
}

static void
hdy_tab_destroy (GtkWidget *widget)
{
  HdyTab *self = HDY_TAB (widget);

  g_clear_pointer (&self->indicator_btn, gtk_widget_unparent);
  g_clear_pointer (&self->icon_stack, gtk_widget_unparent);
  g_clear_pointer (&self->title, gtk_widget_unparent);
  g_clear_pointer (&self->close_btn, gtk_widget_unparent);

  GTK_WIDGET_CLASS (hdy_tab_parent_class)->destroy (widget);
}

static void
hdy_tab_measure (GtkWidget      *widget,
                 GtkOrientation  orientation,
                 gint            for_size,
                 gint           *minimum,
                 gint           *natural,
                 gint           *minimum_baseline,
                 gint           *natural_baseline)
{
  HdyTab *self = HDY_TAB (widget);
  gint min = 0, nat = 0;

  if (orientation == GTK_ORIENTATION_HORIZONTAL) {
    nat = self->pinned ? BASE_WIDTH_PINNED : BASE_WIDTH;

    hdy_css_measure (widget, orientation, NULL, &nat);
  } else {
    gint child_min, child_nat;

    gtk_widget_get_preferred_height (self->icon_stack, &child_min, &child_nat);
    min = MAX (min, child_min);
    nat = MAX (nat, child_nat);

    gtk_widget_get_preferred_height (self->title, &child_min, &child_nat);
    min = MAX (min, child_min);
    nat = MAX (nat, child_nat);

    gtk_widget_get_preferred_height (self->close_btn, &child_min, &child_nat);
    min = MAX (min, child_min);
    nat = MAX (nat, child_nat);

    gtk_widget_get_preferred_height (self->indicator_btn, &child_min, &child_nat);
    min = MAX (min, child_min);
    nat = MAX (nat, child_nat);

    hdy_css_measure (widget, orientation, &min, &nat);
  }

  if (minimum)
    *minimum = min;
  if (natural)
    *natural = nat;
  if (minimum_baseline)
    *minimum_baseline = -1;
  if (natural_baseline)
    *natural_baseline = -1;
}

static void
hdy_tab_get_preferred_width (GtkWidget *widget,
                             gint      *minimum,
                             gint      *natural)
{
  hdy_tab_measure (widget, GTK_ORIENTATION_HORIZONTAL, -1,
                   minimum, natural,
                   NULL, NULL);
}

static void
hdy_tab_get_preferred_height (GtkWidget *widget,
                              gint      *minimum,
                              gint      *natural)
{
  hdy_tab_measure (widget, GTK_ORIENTATION_VERTICAL, -1,
                   minimum, natural,
                   NULL, NULL);
}

static void
hdy_tab_get_preferred_width_for_height (GtkWidget *widget,
                                        gint       height,
                                        gint      *minimum,
                                        gint      *natural)
{
  hdy_tab_measure (widget, GTK_ORIENTATION_HORIZONTAL, height,
                   minimum, natural,
                   NULL, NULL);
}

static void
hdy_tab_get_preferred_height_for_width (GtkWidget *widget,
                                        gint       width,
                                        gint      *minimum,
                                        gint      *natural)
{
  hdy_tab_measure (widget, GTK_ORIENTATION_VERTICAL, width,
                   minimum, natural,
                   NULL, NULL);
}

static inline void
measure_child (GtkWidget *child,
               gint      *width)
{
  if (gtk_widget_get_visible (child))
    gtk_widget_get_preferred_width (child, NULL, width);
  else
    *width = 0;
}

static inline void
allocate_child (GtkWidget     *child,
                GtkAllocation *alloc,
                gint           x,
                gint           width)
{
  GtkAllocation child_alloc = *alloc;

  if (gtk_widget_get_direction (child) == GTK_TEXT_DIR_RTL)
    child_alloc.x += alloc->width - width - x;
  else
    child_alloc.x += x;

  child_alloc.width = width;

  gtk_widget_size_allocate (child, &child_alloc);
}

static void
allocate_contents (HdyTab        *self,
                   GtkAllocation *alloc)
{
  gint indicator_width, close_width, icon_width, title_width;
  gint center_x, center_width = 0;
  gint start_width = 0, end_width = 0;

  measure_child (self->icon_stack, &icon_width);
  measure_child (self->title, &title_width);
  measure_child (self->indicator_btn, &indicator_width);
  measure_child (self->close_btn, &close_width);

  if (gtk_widget_get_visible (self->indicator_btn)) {
    if (self->pinned) {
      /* Center it in a pinned tab */
      allocate_child (self->indicator_btn, alloc,
                      (alloc->width - indicator_width) / 2, indicator_width);
    } else if (self->inverted) {
      allocate_child (self->indicator_btn, alloc,
                      alloc->width - indicator_width, indicator_width);

      end_width = indicator_width;
    } else {
      allocate_child (self->indicator_btn, alloc, 0, indicator_width);

      start_width = indicator_width;
    }
  }

  if (gtk_widget_get_visible (self->close_btn)) {
    if (self->inverted) {
      allocate_child (self->close_btn, alloc, 0, close_width);

      start_width = close_width;
    } else {
      allocate_child (self->close_btn, alloc,
                      alloc->width - close_width, close_width);

      if (self->title_inverted)
        end_width = close_width;
    }
  }

  center_width = MIN (alloc->width - start_width - end_width,
                      icon_width + title_width);
  center_x = CLAMP ((alloc->width - center_width) / 2,
                    start_width,
                    alloc->width - center_width - end_width);

  self->close_overlap = !self->inverted &&
                        !self->title_inverted &&
                        gtk_widget_get_visible (self->title) &&
                        gtk_widget_get_visible (self->close_btn) &&
                        center_x + center_width > alloc->width - close_width;

  if (gtk_widget_get_visible (self->icon_stack)) {
    allocate_child (self->icon_stack, alloc, center_x, icon_width);

    center_x += icon_width;
    center_width -= icon_width;
  }

  if (gtk_widget_get_visible (self->title))
    allocate_child (self->title, alloc, center_x, center_width);
}

static void
hdy_tab_size_allocate (GtkWidget     *widget,
                       GtkAllocation *allocation)
{
  HdyTab *self = HDY_TAB (widget);
  gint width_diff = allocation->width;
  GtkAllocation child_alloc, clip;

  hdy_css_size_allocate_self (widget, allocation);

  gtk_widget_set_allocation (widget, allocation);

  if (self->window)
    gdk_window_move_resize (self->window,
                            allocation->x, allocation->y,
                            allocation->width, allocation->height);

  child_alloc = *allocation;
  child_alloc.x = 0;
  child_alloc.y = 0;

  hdy_css_size_allocate_children (widget, &child_alloc);

  width_diff = MAX (0, width_diff - child_alloc.width);

  if (self->icon_stack && self->indicator_btn && self->title && self->close_btn) {
    gint width = MAX (child_alloc.width, self->display_width - width_diff);

    child_alloc.x += (child_alloc.width - width) / 2;
    child_alloc.width = width;

    if (width >= 0)
      allocate_contents (self, &child_alloc);
  }

  gtk_render_background_get_clip (gtk_widget_get_style_context (widget),
                                  allocation->x, allocation->y,
                                  allocation->width, allocation->height,
                                  &clip);

  gtk_widget_set_clip (widget, &clip);
}

static void
hdy_tab_realize (GtkWidget *widget)
{
  HdyTab *self = HDY_TAB (widget);
  GtkAllocation allocation;
  GdkWindowAttr attributes;
  GdkWindowAttributesType attributes_mask;

  gtk_widget_set_realized (widget, TRUE);

  gtk_widget_get_allocation (widget, &allocation);

  attributes.x = allocation.x;
  attributes.y = allocation.y;
  attributes.width = allocation.width;
  attributes.height = allocation.height;
  attributes.window_type = GDK_WINDOW_CHILD;
  attributes.wclass = GDK_INPUT_OUTPUT;
  attributes.visual = gtk_widget_get_visual (widget);
  attributes.event_mask = gtk_widget_get_events (widget);
  attributes_mask = GDK_WA_X | GDK_WA_Y | GDK_WA_VISUAL;

  self->window = gdk_window_new (gtk_widget_get_parent_window (widget),
                                 &attributes,
                                 attributes_mask);

  gtk_widget_set_window (widget, self->window);
  gtk_widget_register_window (widget, self->window);

  gtk_container_forall (GTK_CONTAINER (self),
                        (GtkCallback) gtk_widget_set_parent_window,
                        self->window);
}

static void
hdy_tab_unrealize (GtkWidget *widget)
{
  HdyTab *self = HDY_TAB (widget);

  GTK_WIDGET_CLASS (hdy_tab_parent_class)->unrealize (widget);

  self->window = NULL;
}

static void
hdy_tab_map (GtkWidget *widget)
{
  HdyTab *self = HDY_TAB (widget);

  GTK_WIDGET_CLASS (hdy_tab_parent_class)->map (widget);

  update_spinner (self);
}

static void
hdy_tab_unmap (GtkWidget *widget)
{
  HdyTab *self = HDY_TAB (widget);

  GTK_WIDGET_CLASS (hdy_tab_parent_class)->unmap (widget);

  update_spinner (self);
}

static gint
get_end_padding (HdyTab *self)
{
  GtkWidget *widget = GTK_WIDGET (self);
  GtkStyleContext *style_context;
  GtkStateFlags state_flags;
  GtkBorder border, padding;

  style_context = gtk_widget_get_style_context (widget);
  state_flags = gtk_widget_get_state_flags (widget);

  gtk_style_context_get_border (style_context, state_flags, &border);
  gtk_style_context_get_padding (style_context, state_flags, &padding);

  if (gtk_widget_get_direction (widget) == GTK_TEXT_DIR_RTL)
    return border.left + padding.left;
  else
    return border.right + padding.right;
}

static gboolean
hdy_tab_draw (GtkWidget *widget,
              cairo_t   *cr)
{
  HdyTab *self = HDY_TAB (widget);
  gboolean draw_fade = self->close_overlap &&
                       gtk_widget_get_opacity (self->close_btn) > 0;

  hdy_css_draw (widget, cr);

  gtk_container_propagate_draw (GTK_CONTAINER (self), self->indicator_btn, cr);
  gtk_container_propagate_draw (GTK_CONTAINER (self), self->icon_stack, cr);

  if (draw_fade) {
    cairo_save (cr);
    cairo_push_group (cr);
  }

  gtk_container_propagate_draw (GTK_CONTAINER (self), self->title, cr);

  if (draw_fade) {
    gint width = gtk_widget_get_allocated_width (widget);
    gint height = gtk_widget_get_allocated_height (widget);
    gint fade_width =
      gtk_widget_get_allocated_width (self->close_btn) +
      get_end_padding (self) +
      gtk_widget_get_margin_end (self->title) +
      FADE_WIDTH;

    ensure_gradient (self);

    if (gtk_widget_get_direction (widget) == GTK_TEXT_DIR_RTL) {
      cairo_translate (cr, fade_width, 0);
      cairo_scale (cr, -1, 1);
    } else {
      cairo_translate (cr, width - fade_width, 0);
    }

    cairo_set_source (cr, self->gradient);
    cairo_rectangle (cr, 0, 0, fade_width, height);
    cairo_set_operator (cr, CAIRO_OPERATOR_DEST_OUT);
    cairo_fill (cr);

    cairo_pop_group_to_source (cr);
    cairo_paint (cr);
    cairo_restore (cr);
  }

  gtk_container_propagate_draw (GTK_CONTAINER (self), self->close_btn, cr);

  return GDK_EVENT_PROPAGATE;
}

static void
hdy_tab_direction_changed (GtkWidget        *widget,
                           GtkTextDirection  previous_direction)
{
  HdyTab *self = HDY_TAB (widget);

  update_title (self);

  GTK_WIDGET_CLASS (hdy_tab_parent_class)->direction_changed (widget,
                                                              previous_direction);
}

static void
hdy_tab_add (GtkContainer *container,
             GtkWidget    *widget)
{
  HdyTab *self = HDY_TAB (container);

  gtk_widget_set_parent (widget, GTK_WIDGET (self));

  if (self->window)
    gtk_widget_set_parent_window (widget, self->window);
}

static void
hdy_tab_remove (GtkContainer *container,
                GtkWidget    *widget)
{
  gtk_container_forall (container,
                        (GtkCallback) gtk_widget_unparent,
                        NULL);
}

static void
hdy_tab_forall (GtkContainer *container,
                gboolean      include_internals,
                GtkCallback   callback,
                gpointer      callback_data)
{
  HdyTab *self = HDY_TAB (container);

  if (!include_internals)
    return;

  if (self->indicator_btn)
    callback (self->indicator_btn, callback_data);
  if (self->icon_stack)
    callback (self->icon_stack, callback_data);
  if (self->title)
    callback (self->title, callback_data);
  if (self->close_btn)
    callback (self->close_btn, callback_data);
}

static void
hdy_tab_constructed (GObject *object)
{
  HdyTab *self = HDY_TAB (object);

  G_OBJECT_CLASS (hdy_tab_parent_class)->constructed (object);

  if (self->pinned) {
    gtk_style_context_add_class (gtk_widget_get_style_context (GTK_WIDGET (self)),
                                 "pinned");
    gtk_widget_hide (self->title);
    gtk_widget_hide (self->close_btn);
    gtk_widget_set_margin_start (self->icon_stack, 0);
    gtk_widget_set_margin_end (self->icon_stack, 0);
  }

  g_signal_connect_object (self->view, "notify::default-icon",
                           G_CALLBACK (update_icons), self,
                           G_CONNECT_SWAPPED);
}

static void
hdy_tab_get_property (GObject    *object,
                      guint       prop_id,
                      GValue     *value,
                      GParamSpec *pspec)
{
  HdyTab *self = HDY_TAB (object);

  switch (prop_id) {
  case PROP_VIEW:
    g_value_set_object (value, self->view);
    break;

  case PROP_PAGE:
    g_value_set_object (value, self->page);
    break;

  case PROP_PINNED:
    g_value_set_boolean (value, self->pinned);
    break;

  case PROP_DRAGGING:
    g_value_set_boolean (value, hdy_tab_get_dragging (self));
    break;

  case PROP_DISPLAY_WIDTH:
    g_value_set_int (value, hdy_tab_get_display_width (self));
    break;

  case PROP_HOVERING:
    g_value_set_boolean (value, hdy_tab_get_hovering (self));
    break;

  case PROP_INVERTED:
    g_value_set_boolean (value, hdy_tab_get_inverted (self));
    break;

    default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_tab_set_property (GObject      *object,
                      guint         prop_id,
                      const GValue *value,
                      GParamSpec   *pspec)
{
  HdyTab *self = HDY_TAB (object);

  switch (prop_id) {
  case PROP_VIEW:
    self->view = g_value_get_object (value);
    break;

  case PROP_PAGE:
    hdy_tab_set_page (self, g_value_get_object (value));
    break;

  case PROP_PINNED:
    self->pinned = g_value_get_boolean (value);
    break;

  case PROP_DRAGGING:
    hdy_tab_set_dragging (self, g_value_get_boolean (value));
    break;

  case PROP_DISPLAY_WIDTH:
    hdy_tab_set_display_width (self, g_value_get_int (value));
    break;

  case PROP_HOVERING:
    hdy_tab_set_hovering (self, g_value_get_boolean (value));
    break;

  case PROP_INVERTED:
    hdy_tab_set_inverted (self, g_value_get_boolean (value));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_tab_dispose (GObject *object)
{
  HdyTab *self = HDY_TAB (object);

  hdy_tab_set_page (self, NULL);
  g_clear_object (&self->gesture);

  G_OBJECT_CLASS (hdy_tab_parent_class)->dispose (object);
}

static void
hdy_tab_finalize (GObject *object)
{
  HdyTab *self = HDY_TAB (object);

  g_clear_pointer (&self->gradient, cairo_pattern_destroy);

  G_OBJECT_CLASS (hdy_tab_parent_class)->finalize (object);
}

static void
hdy_tab_class_init (HdyTabClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);
  GtkContainerClass *container_class = GTK_CONTAINER_CLASS (klass);

  object_class->dispose = hdy_tab_dispose;
  object_class->finalize = hdy_tab_finalize;
  object_class->constructed = hdy_tab_constructed;
  object_class->get_property = hdy_tab_get_property;
  object_class->set_property = hdy_tab_set_property;

  widget_class->destroy = hdy_tab_destroy;
  widget_class->get_preferred_width = hdy_tab_get_preferred_width;
  widget_class->get_preferred_height = hdy_tab_get_preferred_height;
  widget_class->get_preferred_width_for_height = hdy_tab_get_preferred_width_for_height;
  widget_class->get_preferred_height_for_width = hdy_tab_get_preferred_height_for_width;
  widget_class->size_allocate = hdy_tab_size_allocate;
  widget_class->realize = hdy_tab_realize;
  widget_class->unrealize = hdy_tab_unrealize;
  widget_class->map = hdy_tab_map;
  widget_class->unmap = hdy_tab_unmap;
  widget_class->draw = hdy_tab_draw;
  widget_class->direction_changed = hdy_tab_direction_changed;

  container_class->add = hdy_tab_add;
  container_class->remove = hdy_tab_remove;
  container_class->forall = hdy_tab_forall;

  props[PROP_VIEW] =
    g_param_spec_object ("view",
                         _("View"),
                         _("View"),
                         HDY_TYPE_TAB_VIEW,
                         G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY);

  props[PROP_PINNED] =
    g_param_spec_boolean ("pinned",
                          _("Pinned"),
                          _("Pinned"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY);

  props[PROP_DRAGGING] =
    g_param_spec_boolean ("dragging",
                          _("Dragging"),
                          _("Dragging"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_PAGE] =
    g_param_spec_object ("page",
                         _("Page"),
                         _("Page"),
                         HDY_TYPE_TAB_PAGE,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_DISPLAY_WIDTH] =
    g_param_spec_int ("display-width",
                      _("Display Width"),
                      _("Display Width"),
                      0, G_MAXINT, 0,
                      G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_HOVERING] =
    g_param_spec_boolean ("hovering",
                          _("Hovering"),
                          _("Hovering"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  props[PROP_INVERTED] =
    g_param_spec_boolean ("inverted",
                          _("Inverted"),
                          _("Inverted"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  g_object_class_install_properties (object_class, LAST_PROP, props);

  gtk_widget_class_set_template_from_resource (widget_class,
                                               "/sm/puri/handy/ui/hdy-tab.ui");
  gtk_widget_class_bind_template_child (widget_class, HdyTab, title);
  gtk_widget_class_bind_template_child (widget_class, HdyTab, icon_stack);
  gtk_widget_class_bind_template_child (widget_class, HdyTab, icon);
  gtk_widget_class_bind_template_child (widget_class, HdyTab, spinner);
  gtk_widget_class_bind_template_child (widget_class, HdyTab, indicator_icon);
  gtk_widget_class_bind_template_child (widget_class, HdyTab, indicator_btn);
  gtk_widget_class_bind_template_child (widget_class, HdyTab, close_btn);
  gtk_widget_class_bind_template_callback (widget_class, close_clicked_cb);
  gtk_widget_class_bind_template_callback (widget_class, indicator_clicked_cb);

  gtk_widget_class_set_css_name (widget_class, "tab");
}

static void
hdy_tab_init (HdyTab *self)
{
  g_type_ensure (HDY_TYPE_FADING_LABEL);

  gtk_widget_init_template (GTK_WIDGET (self));

  self->gesture = gtk_gesture_drag_new (GTK_WIDGET (self));
}

HdyTab *
hdy_tab_new (HdyTabView *view,
             gboolean    pinned)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (view), NULL);

  return g_object_new (HDY_TYPE_TAB,
                       "view", view,
                       "pinned", pinned,
                       NULL);
}

void
hdy_tab_set_page (HdyTab     *self,
                  HdyTabPage *page)
{
  g_return_if_fail (HDY_IS_TAB (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page) || page == NULL);

  if (self->page == page)
    return;

  if (self->page) {
    g_signal_handlers_disconnect_by_func (self->page, update_selected, self);
    g_signal_handlers_disconnect_by_func (self->page, update_title, self);
    g_signal_handlers_disconnect_by_func (self->page, update_tooltip, self);
    g_signal_handlers_disconnect_by_func (self->page, update_icons, self);
    g_signal_handlers_disconnect_by_func (self->page, update_indicator, self);
    g_signal_handlers_disconnect_by_func (self->page, update_needs_attention, self);
    g_signal_handlers_disconnect_by_func (self->page, update_loading, self);
    g_clear_pointer (&self->title_binding, g_binding_unbind);
  }

  g_set_object (&self->page, page);

  if (self->page) {
    update_selected (self);
    update_state (self);
    update_title (self);
    update_tooltip (self);
    update_spinner (self);
    update_icons (self);
    update_indicator (self);
    update_needs_attention (self);
    update_loading (self);

    g_signal_connect_object (self->page, "notify::selected",
                             G_CALLBACK (update_selected), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->page, "notify::title",
                             G_CALLBACK (update_title), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->page, "notify::tooltip",
                             G_CALLBACK (update_tooltip), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->page, "notify::icon",
                             G_CALLBACK (update_icons), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->page, "notify::indicator-icon",
                             G_CALLBACK (update_icons), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->page, "notify::indicator-activatable",
                             G_CALLBACK (update_indicator), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->page, "notify::needs-attention",
                             G_CALLBACK (update_needs_attention), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->page, "notify::loading",
                             G_CALLBACK (update_loading), self,
                             G_CONNECT_SWAPPED);

    self->title_binding = g_object_bind_property (self->page, "title",
                                                  self->title, "label",
                                                  G_BINDING_SYNC_CREATE);

  }

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_PAGE]);
}

gint
hdy_tab_get_display_width (HdyTab *self)
{
  g_return_val_if_fail (HDY_IS_TAB (self), 0);

  return self->display_width;
}

void
hdy_tab_set_display_width (HdyTab *self,
                           gint    width)
{
  g_return_if_fail (HDY_IS_TAB (self));
  g_return_if_fail (width >= 0);

  if (self->display_width == width)
    return;

  self->display_width = width;

  gtk_widget_queue_resize (GTK_WIDGET (self));

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_DISPLAY_WIDTH]);
}

gboolean
hdy_tab_get_hovering (HdyTab *self)
{
  g_return_val_if_fail (HDY_IS_TAB (self), FALSE);

  return self->hovering;
}

void
hdy_tab_set_hovering (HdyTab   *self,
                      gboolean  hovering)
{
  g_return_if_fail (HDY_IS_TAB (self));

  hovering = !!hovering;

  if (self->hovering == hovering)
    return;

  self->hovering = hovering;

  update_state (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_HOVERING]);
}

gboolean
hdy_tab_get_dragging (HdyTab *self)
{
  g_return_val_if_fail (HDY_IS_TAB (self), FALSE);

  return self->dragging;
}

void
hdy_tab_set_dragging (HdyTab   *self,
                      gboolean  dragging)
{
  g_return_if_fail (HDY_IS_TAB (self));

  dragging = !!dragging;

  if (self->dragging == dragging)
    return;

  self->dragging = dragging;

  update_state (self);
  update_selected (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_DRAGGING]);
}

gboolean
hdy_tab_get_inverted (HdyTab *self)
{
  g_return_val_if_fail (HDY_IS_TAB (self), FALSE);

  return self->inverted;
}

void
hdy_tab_set_inverted (HdyTab   *self,
                      gboolean  inverted)
{
  g_return_if_fail (HDY_IS_TAB (self));

  inverted = !!inverted;

  if (self->inverted == inverted)
    return;

  self->inverted = inverted;

  gtk_widget_queue_allocate (GTK_WIDGET (self));

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_INVERTED]);
}

void
hdy_tab_set_fully_visible (HdyTab   *self,
                           gboolean  fully_visible)
{
  g_return_if_fail (HDY_IS_TAB (self));

  fully_visible = !!fully_visible;

  if (self->fully_visible == fully_visible)
    return;

  self->fully_visible = fully_visible;

  update_state (self);
  update_indicator (self);
}
