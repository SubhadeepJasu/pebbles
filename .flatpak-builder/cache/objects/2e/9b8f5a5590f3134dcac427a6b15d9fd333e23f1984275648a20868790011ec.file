#include "hdy-tab-view-demo-window.h"

#include <glib/gi18n.h>

struct _HdyTabViewDemoWindow
{
  HdyWindow parent_instance;
  HdyTabView *view;
  HdyTabBar *tab_bar;

  GActionMap *tab_action_group;

  HdyTabPage *menu_page;
};

G_DEFINE_TYPE (HdyTabViewDemoWindow, hdy_tab_view_demo_window, HDY_TYPE_WINDOW)

static void
window_new (GSimpleAction *action,
            GVariant      *parameter,
            gpointer       user_data)
{
  HdyTabViewDemoWindow *window = hdy_tab_view_demo_window_new ();

  hdy_tab_view_demo_window_prepopulate (window);

  gtk_window_present (GTK_WINDOW (window));
}

static GIcon *
get_random_icon (void)
{
  GtkIconTheme *theme = gtk_icon_theme_get_default ();
  GList *list;
  gint index;
  GIcon *icon;

  list = gtk_icon_theme_list_icons (theme, "MimeTypes");

  index = g_random_int_range (0, g_list_length (list));
  icon = g_themed_icon_new (g_list_nth_data (list, index));

  g_list_free_full (list, g_free);

  return icon;
}

static gboolean
text_to_tooltip (GBinding     *binding,
                 const GValue *input,
                 GValue       *output,
                 gpointer      user_data)
{
  const gchar *title = g_value_get_string (input);
  gchar *tooltip = g_markup_printf_escaped (_("An elaborate tooltip for <b>%s</b>"), title);

  g_value_take_string (output, tooltip);

  return TRUE;
}

static HdyTabPage *
add_page (HdyTabViewDemoWindow *self,
          HdyTabPage           *parent,
          const gchar          *title,
          GIcon                *icon)
{
  GtkWidget *content;
  HdyTabPage *page;

  content = g_object_new (GTK_TYPE_ENTRY,
                          "visible", TRUE,
                          "text", title,
                          "halign", GTK_ALIGN_CENTER,
                          "valign", GTK_ALIGN_CENTER,
                          NULL);

  page = hdy_tab_view_add_page (self->view, GTK_WIDGET (content), parent);

  g_object_bind_property (content, "text",
                          page, "title",
                          G_BINDING_SYNC_CREATE | G_BINDING_BIDIRECTIONAL);
  g_object_bind_property_full (content, "text",
                               page, "tooltip",
                               G_BINDING_SYNC_CREATE,
                               text_to_tooltip, NULL,
                               NULL, NULL);

  hdy_tab_page_set_icon (page, icon);
  hdy_tab_page_set_indicator_activatable (page, TRUE);

  return page;
}

static void
tab_new (GSimpleAction *action,
         GVariant      *parameter,
         gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);
  g_autofree gchar *title = NULL;
  HdyTabPage *page;
  GtkWidget *content;
  GIcon *icon;
  static gint next_page = 1;

  title = g_strdup_printf (_("Tab %d"), next_page);
  icon = get_random_icon ();

  page = add_page (self, NULL, title, icon);
  content = hdy_tab_page_get_child (page);

  hdy_tab_view_set_selected_page (self->view, page);

  gtk_widget_grab_focus (content);

  next_page++;
}

static HdyTabPage *
get_current_page (HdyTabViewDemoWindow *self)
{
  if (self->menu_page)
    return self->menu_page;

  return hdy_tab_view_get_selected_page (self->view);
}

static void
tab_pin (GSimpleAction *action,
         GVariant      *parameter,
         gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);

  hdy_tab_view_set_page_pinned (self->view, get_current_page (self), TRUE);
}

static void
tab_unpin (GSimpleAction *action,
           GVariant      *parameter,
           gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);

  hdy_tab_view_set_page_pinned (self->view, get_current_page (self), FALSE);
}

static void
tab_close (GSimpleAction *action,
           GVariant      *parameter,
           gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);

  hdy_tab_view_close_page (self->view, get_current_page (self));
}

static void
tab_close_other (GSimpleAction *action,
                 GVariant      *parameter,
                 gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);

  hdy_tab_view_close_other_pages (self->view, get_current_page (self));
}

static void
tab_close_before (GSimpleAction *action,
                  GVariant      *parameter,
                  gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);

  hdy_tab_view_close_pages_before (self->view, get_current_page (self));
}

static void
tab_close_after (GSimpleAction *action,
                 GVariant      *parameter,
                 gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);

  hdy_tab_view_close_pages_after (self->view, get_current_page (self));
}

static void
tab_move_to_new_window (GSimpleAction *action,
                        GVariant      *parameter,
                        gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);

  HdyTabViewDemoWindow *window = hdy_tab_view_demo_window_new ();

  hdy_tab_view_transfer_page (self->view,
                              self->menu_page,
                              window->view,
                              0);

  gtk_window_present (GTK_WINDOW (window));
}

static void
tab_change_needs_attention (GSimpleAction *action,
                            GVariant      *parameter,
                            gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);
  gboolean need_attention = g_variant_get_boolean (parameter);

  hdy_tab_page_set_needs_attention (get_current_page (self), need_attention);
  g_simple_action_set_state (action, g_variant_new_boolean (need_attention));
}

static void
tab_change_loading (GSimpleAction *action,
                    GVariant      *parameter,
                    gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);
  gboolean loading = g_variant_get_boolean (parameter);

  hdy_tab_page_set_loading (get_current_page (self), loading);
  g_simple_action_set_state (action, g_variant_new_boolean (loading));
}

static GIcon *
get_indicator_icon (HdyTabPage *page)
{
  gboolean muted;

  muted = GPOINTER_TO_INT (g_object_get_data (G_OBJECT (page),
                                              "hdy-tab-view-demo-muted"));

  if (muted)
    return g_themed_icon_new ("tab-audio-muted-symbolic");
  else
    return g_themed_icon_new ("tab-audio-playing-symbolic");
}

static void
tab_change_indicator (GSimpleAction *action,
                      GVariant      *parameter,
                      gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);
  gboolean indicator = g_variant_get_boolean (parameter);
  g_autoptr (GIcon) icon = NULL;

  if (indicator)
    icon = get_indicator_icon (get_current_page (self));

  hdy_tab_page_set_indicator_icon (get_current_page (self), icon);
  g_simple_action_set_state (action, g_variant_new_boolean (indicator));
}

static void
tab_change_icon (GSimpleAction *action,
                 GVariant      *parameter,
                 gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);
  gboolean enable_icon = g_variant_get_boolean (parameter);

  if (enable_icon) {
    g_autoptr (GIcon) icon = get_random_icon ();

    hdy_tab_page_set_icon (get_current_page (self), icon);
  } else {
    hdy_tab_page_set_icon (get_current_page (self), NULL);
  }

  g_simple_action_set_state (action, g_variant_new_boolean (enable_icon));
}

static void
tab_refresh_icon (GSimpleAction *action,
                  GVariant      *parameter,
                  gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);
  g_autoptr (GIcon) icon = get_random_icon ();

  hdy_tab_page_set_icon (get_current_page (self), icon);
}

static void
tab_duplicate (GSimpleAction *action,
               GVariant      *parameter,
               gpointer       user_data)
{
  HdyTabViewDemoWindow *self = HDY_TAB_VIEW_DEMO_WINDOW (user_data);
  HdyTabPage *parent = get_current_page (self);
  HdyTabPage *page;

  page = add_page (self, parent,
                   hdy_tab_page_get_title (parent),
                   hdy_tab_page_get_icon (parent));

  hdy_tab_page_set_indicator_icon (page, hdy_tab_page_get_indicator_icon (parent));
  hdy_tab_page_set_loading (page, hdy_tab_page_get_loading (parent));
  hdy_tab_page_set_needs_attention (page, hdy_tab_page_get_needs_attention (parent));

  g_object_set_data (G_OBJECT (page),
                     "hdy-tab-view-demo-muted",
                     g_object_get_data (G_OBJECT (parent),
                                        "hdy-tab-view-demo-muted"));

  hdy_tab_view_set_selected_page (self->view, page);
}

static GActionEntry action_entries[] = {
  { "window-new", window_new },
  { "tab-new", tab_new },
};

static GActionEntry tab_action_entries[] = {
  { "pin", tab_pin },
  { "unpin", tab_unpin },
  { "close", tab_close },
  { "close-other", tab_close_other },
  { "close-before", tab_close_before },
  { "close-after", tab_close_after },
  { "move-to-new-window", tab_move_to_new_window },
  { "needs-attention", NULL, NULL, "false", tab_change_needs_attention },
  { "loading", NULL, NULL, "false", tab_change_loading },
  { "indicator", NULL, NULL, "false", tab_change_indicator },
  { "icon", NULL, NULL, "false", tab_change_icon },
  { "refresh-icon", tab_refresh_icon },
  { "duplicate", tab_duplicate },
};

static inline void
set_tab_action_enabled (HdyTabViewDemoWindow *self,
                        const gchar          *name,
                        gboolean              enabled)
{
  GAction *action = g_action_map_lookup_action (self->tab_action_group, name);

  g_assert (G_IS_SIMPLE_ACTION (action));

  g_simple_action_set_enabled (G_SIMPLE_ACTION (action),
                               enabled);
}

static inline void
set_tab_action_state (HdyTabViewDemoWindow *self,
                      const gchar          *name,
                      gboolean              state)
{
  GAction *action = g_action_map_lookup_action (self->tab_action_group, name);

  g_assert (G_IS_SIMPLE_ACTION (action));

  g_simple_action_set_state (G_SIMPLE_ACTION (action),
                             g_variant_new_boolean (state));
}

static void
page_detached_cb (HdyTabViewDemoWindow *self,
                  HdyTabPage           *page)
{
  if (!hdy_tab_view_get_n_pages (self->view))
    gtk_window_close (GTK_WINDOW (self));
}

static void
setup_menu_cb (HdyTabViewDemoWindow *self,
               HdyTabPage           *page,
               HdyTabView           *view)
{
  HdyTabPage *prev = NULL;
  gboolean can_close_before = TRUE, can_close_after = TRUE;
  gboolean pinned = FALSE, prev_pinned;
  gboolean has_icon = FALSE;
  guint n_pages, pos;

  self->menu_page = page;

  n_pages = hdy_tab_view_get_n_pages (self->view);

  if (page) {
    pos = hdy_tab_view_get_page_position (self->view, page);

    if (pos > 0)
      prev = hdy_tab_view_get_nth_page (self->view, pos - 1);

    pinned = hdy_tab_page_get_pinned (page);
    prev_pinned = prev && hdy_tab_page_get_pinned (prev);

    can_close_before = !pinned && prev && !prev_pinned;
    can_close_after = pos < n_pages - 1;

    has_icon = hdy_tab_page_get_icon (page) != NULL;
  }

  set_tab_action_enabled (self, "pin", !page || !pinned);
  set_tab_action_enabled (self, "unpin", !page || pinned);
  set_tab_action_enabled (self, "close", !page || !pinned);
  set_tab_action_enabled (self, "close-before", can_close_before);
  set_tab_action_enabled (self, "close-after", can_close_after);
  set_tab_action_enabled (self, "close-other", can_close_before || can_close_after);
  set_tab_action_enabled (self, "move-to-new-window", !page || (!pinned && n_pages > 1));
  set_tab_action_enabled (self, "refresh-icon", has_icon);

  if (page) {
    set_tab_action_state (self, "icon", has_icon);
    set_tab_action_state (self, "loading", hdy_tab_page_get_loading (page));
    set_tab_action_state (self, "needs-attention", hdy_tab_page_get_needs_attention (page));
    set_tab_action_state (self, "indicator", hdy_tab_page_get_indicator_icon (page) != NULL);
  }
}

static HdyTabView *
create_window_cb (HdyTabViewDemoWindow *self)
{
  HdyTabViewDemoWindow *window = hdy_tab_view_demo_window_new ();

  gtk_window_set_position (GTK_WINDOW (window), GTK_WIN_POS_MOUSE);
  gtk_window_present (GTK_WINDOW (window));

  return window->view;
}

static void
indicator_activated_cb (HdyTabViewDemoWindow *self,
                        HdyTabPage           *page)
{
  g_autoptr (GIcon) icon = NULL;
  gboolean muted;

  muted = GPOINTER_TO_INT (g_object_get_data (G_OBJECT (page),
                                              "hdy-tab-view-demo-muted"));

  g_object_set_data (G_OBJECT (page),
                     "hdy-tab-view-demo-muted",
                     GINT_TO_POINTER (!muted));

  icon = get_indicator_icon (page);

  hdy_tab_page_set_indicator_icon (page, icon);
}

static void
extra_drag_data_received_cb (HdyTabViewDemoWindow *self,
                             HdyTabPage           *page,
                             GdkDragContext       *context,
                             GtkSelectionData     *selection_data,
                             guint                 info,
                             guint                 time)
{
  g_autofree gchar *text = NULL;

  if (gtk_selection_data_get_length (selection_data) < 0)
    return;

  text = (gchar *) gtk_selection_data_get_text (selection_data);

  hdy_tab_page_set_title (page, text);
}

static void
hdy_tab_view_demo_window_class_init (HdyTabViewDemoWindowClass *klass)
{
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);

  gtk_widget_class_set_template_from_resource (widget_class, "/sm/puri/Handy/Demo/ui/hdy-tab-view-demo-window.ui");
  gtk_widget_class_bind_template_child (widget_class, HdyTabViewDemoWindow, view);
  gtk_widget_class_bind_template_child (widget_class, HdyTabViewDemoWindow, tab_bar);
  gtk_widget_class_bind_template_callback (widget_class, page_detached_cb);
  gtk_widget_class_bind_template_callback (widget_class, setup_menu_cb);
  gtk_widget_class_bind_template_callback (widget_class, create_window_cb);
  gtk_widget_class_bind_template_callback (widget_class, indicator_activated_cb);
  gtk_widget_class_bind_template_callback (widget_class, extra_drag_data_received_cb);
}

static void
hdy_tab_view_demo_window_init (HdyTabViewDemoWindow *self)
{
  GtkTargetList *target_list;
  GActionMap *action_map;

  gtk_widget_init_template (GTK_WIDGET (self));

  action_map = G_ACTION_MAP (g_simple_action_group_new ());
  g_action_map_add_action_entries (action_map,
                                   action_entries,
                                   G_N_ELEMENTS (action_entries),
                                   self);
  gtk_widget_insert_action_group (GTK_WIDGET (self),
                                  "win",
                                  G_ACTION_GROUP (action_map));

  self->tab_action_group = G_ACTION_MAP (g_simple_action_group_new ());
  g_action_map_add_action_entries (self->tab_action_group,
                                   tab_action_entries,
                                   G_N_ELEMENTS (tab_action_entries),
                                   self);

  gtk_widget_insert_action_group (GTK_WIDGET (self),
                                  "tab",
                                  G_ACTION_GROUP (self->tab_action_group));

  target_list = gtk_target_list_new (NULL, 0);
  gtk_target_list_add_text_targets (target_list, 0);

  hdy_tab_bar_set_extra_drag_dest_targets (self->tab_bar, target_list);

  gtk_target_list_unref (target_list);
}

HdyTabViewDemoWindow *
hdy_tab_view_demo_window_new (void)
{
  return g_object_new (HDY_TYPE_TAB_VIEW_DEMO_WINDOW, NULL);
}

void
hdy_tab_view_demo_window_prepopulate (HdyTabViewDemoWindow *self)
{
  tab_new (NULL, NULL, self);
  tab_new (NULL, NULL, self);
  tab_new (NULL, NULL, self);
}
