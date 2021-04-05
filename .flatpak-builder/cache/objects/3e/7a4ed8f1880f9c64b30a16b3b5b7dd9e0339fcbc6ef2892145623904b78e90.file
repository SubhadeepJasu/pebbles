/*
 * Copyright (C) 2020 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1+
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#include "config.h"
#include <glib/gi18n-lib.h>

#include "hdy-tab-bar-private.h"
#include "hdy-tab-box-private.h"

/**
 * SECTION:hdy-tab-bar
 * @short_description: A tab bar for #HdyTabView
 * @title: HdyTabBar
 * @See_also: #HdyTabView
 *
 * The #HdyTabBar widget is a tab bar that can be used with conjunction with
 * #HdyTabView.
 *
 * #HdyTabBar can autohide and can optionally contain action widgets on both
 * sides of the tabs.
 *
 * When there's not enough space to show all the tabs, #HdyTabBar will scroll
 * them. Pinned tabs always stay visible and aren't a part of the scrollable
 * area.
 *
 * # CSS nodes
 *
 * #HdyTabBar has a single CSS node with name tabbar.
 *
 * Since: 1.2
 */

struct _HdyTabBar
{
  GtkBin parent_instance;

  GtkRevealer *revealer;
  GtkBin *start_action_bin;
  GtkBin *end_action_bin;

  HdyTabBox *box;
  GtkViewport *viewport;
  GtkScrolledWindow *scrolled_window;

  HdyTabBox *pinned_box;
  GtkViewport *pinned_viewport;
  GtkScrolledWindow *pinned_scrolled_window;

  HdyTabView *view;
  gboolean autohide;

  GtkTargetList *extra_drag_dest_targets;

  gboolean is_overflowing;
  gboolean resize_frozen;
};

static void hdy_tab_bar_buildable_init (GtkBuildableIface *iface);

G_DEFINE_TYPE_WITH_CODE (HdyTabBar, hdy_tab_bar, GTK_TYPE_BIN,
                         G_IMPLEMENT_INTERFACE (GTK_TYPE_BUILDABLE,
                         hdy_tab_bar_buildable_init))

enum {
  PROP_0,
  PROP_VIEW,
  PROP_START_ACTION_WIDGET,
  PROP_END_ACTION_WIDGET,
  PROP_AUTOHIDE,
  PROP_TABS_REVEALED,
  PROP_EXPAND_TABS,
  PROP_INVERTED,
  PROP_EXTRA_DRAG_DEST_TARGETS,
  PROP_IS_OVERFLOWING,
  LAST_PROP
};

static GParamSpec *props[LAST_PROP];

enum {
  SIGNAL_EXTRA_DRAG_DATA_RECEIVED,
  SIGNAL_LAST_SIGNAL,
};

static guint signals[SIGNAL_LAST_SIGNAL];

static void
set_tabs_revealed (HdyTabBar *self,
                   gboolean   tabs_revealed)
{
  if (tabs_revealed == hdy_tab_bar_get_tabs_revealed (self))
    return;

  gtk_revealer_set_reveal_child (self->revealer, tabs_revealed);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_TABS_REVEALED]);
}

static void
update_autohide_cb (HdyTabBar *self)
{
  gint n_tabs = 0, n_pinned_tabs = 0;
  gboolean is_transferring_page;

  if (!self->view) {
    set_tabs_revealed (self, FALSE);

    return;
  }

  if (!self->autohide) {
    set_tabs_revealed (self, TRUE);

    return;
  }

  n_tabs = hdy_tab_view_get_n_pages (self->view);
  n_pinned_tabs = hdy_tab_view_get_n_pinned_pages (self->view);
  is_transferring_page = hdy_tab_view_get_is_transferring_page (self->view);

  set_tabs_revealed (self, n_tabs > 1 || n_pinned_tabs >= 1 || is_transferring_page);
}

static void
notify_selected_page_cb (HdyTabBar *self)
{
  HdyTabPage *page = hdy_tab_view_get_selected_page (self->view);

  if (!page)
    return;

  if (hdy_tab_page_get_pinned (page)) {
    hdy_tab_box_select_page (self->pinned_box, page);
    hdy_tab_box_select_page (self->box, page);
  } else {
    hdy_tab_box_select_page (self->box, page);
    hdy_tab_box_select_page (self->pinned_box, page);
  }
}

static void
notify_pinned_cb (HdyTabPage *page,
                  GParamSpec *pspec,
                  HdyTabBar  *self)
{
  HdyTabBox *from, *to;
  gboolean should_focus;

  if (hdy_tab_page_get_pinned (page)) {
    from = self->box;
    to = self->pinned_box;
  } else {
    from = self->pinned_box;
    to = self->box;
  }

  should_focus = hdy_tab_box_is_page_focused (from, page);

  hdy_tab_box_detach_page (from, page);
  hdy_tab_box_attach_page (to, page, hdy_tab_view_get_n_pinned_pages (self->view));

  if (should_focus)
    hdy_tab_box_try_focus_selected_tab (to);
}

static void
page_attached_cb (HdyTabBar  *self,
                  HdyTabPage *page,
                  gint        position)
{
  g_signal_connect_object (page, "notify::pinned",
                           G_CALLBACK (notify_pinned_cb), self,
                           0);
}

static void
page_detached_cb (HdyTabBar  *self,
                  HdyTabPage *page,
                  gint        position)
{
  g_signal_handlers_disconnect_by_func (page, notify_pinned_cb, self);
}

static void
update_needs_attention (HdyTabBar *self,
                        gboolean   pinned)
{
  GtkStyleContext *context;
  gboolean left, right;

  g_object_get (pinned ? self->pinned_box : self->box,
                "needs-attention-left", &left,
                "needs-attention-right", &right,
                NULL);

  if (pinned)
    context = gtk_widget_get_style_context (GTK_WIDGET (self->pinned_scrolled_window));
  else
    context = gtk_widget_get_style_context (GTK_WIDGET (self->scrolled_window));

  if (left)
    gtk_style_context_add_class (context, "needs-attention-left");
  else
    gtk_style_context_remove_class (context, "needs-attention-left");

  if (right)
    gtk_style_context_add_class (context, "needs-attention-right");
  else
    gtk_style_context_remove_class (context, "needs-attention-right");
}

static void
notify_needs_attention_cb (HdyTabBar *self)
{
  update_needs_attention (self, FALSE);
}

static void
notify_needs_attention_pinned_cb (HdyTabBar *self)
{
  update_needs_attention (self, TRUE);
}

static inline gboolean
is_overflowing (GtkAdjustment *adj)
{
  gdouble lower, upper, page_size;

  lower = gtk_adjustment_get_lower (adj);
  upper = gtk_adjustment_get_upper (adj);
  page_size = gtk_adjustment_get_page_size (adj);
  return upper - lower > page_size;
}

static void
update_is_overflowing (HdyTabBar *self)
{
  GtkAdjustment *adj = gtk_scrolled_window_get_hadjustment (self->scrolled_window);
  GtkAdjustment *pinned_adj = gtk_scrolled_window_get_hadjustment (self->pinned_scrolled_window);
  gboolean overflowing = is_overflowing (adj) || is_overflowing (pinned_adj);

  if (overflowing == self->is_overflowing)
    return;

  overflowing |= self->resize_frozen;

  if (overflowing == self->is_overflowing)
    return;

  self->is_overflowing = overflowing;

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_IS_OVERFLOWING]);
}

static void
notify_resize_frozen_cb (HdyTabBar *self)
{
  gboolean frozen, pinned_frozen;

  g_object_get (self->box, "resize-frozen", &frozen, NULL);
  g_object_get (self->pinned_box, "resize-frozen", &pinned_frozen, NULL);

  self->resize_frozen = frozen || pinned_frozen;

  update_is_overflowing (self);
}

static void
stop_kinetic_scrolling_cb (GtkScrolledWindow *scrolled_window)
{
  /* HACK: Need to cancel kinetic scrolling. If only the built-in adjustment
   * animation API was public, we wouldn't have to do any of this... */
  gtk_scrolled_window_set_kinetic_scrolling (scrolled_window, FALSE);
  gtk_scrolled_window_set_kinetic_scrolling (scrolled_window, TRUE);
}

static void
extra_drag_data_received_cb (HdyTabBar        *self,
                             HdyTabPage       *page,
                             GdkDragContext   *context,
                             GtkSelectionData *selection_data,
                             guint             info,
                             guint             time)
{
  g_signal_emit (self, signals[SIGNAL_EXTRA_DRAG_DATA_RECEIVED], 0,
                 page, context, selection_data, info, time);
}

static void
view_destroy_cb (HdyTabBar *self)
{
  hdy_tab_bar_set_view (self, NULL);
}

static void
hdy_tab_bar_destroy (GtkWidget *widget)
{
  gtk_container_forall (GTK_CONTAINER (widget), (GtkCallback) gtk_widget_destroy, NULL);

  GTK_WIDGET_CLASS (hdy_tab_bar_parent_class)->destroy (widget);
}

static gboolean
hdy_tab_bar_focus (GtkWidget        *widget,
                   GtkDirectionType  direction)
{
  HdyTabBar *self = HDY_TAB_BAR (widget);
  gboolean is_rtl;
  GtkDirectionType start, end;

  if (!hdy_tab_bar_get_tabs_revealed (self))
    return GDK_EVENT_PROPAGATE;

  if (!gtk_container_get_focus_child (GTK_CONTAINER (self)))
    return gtk_widget_child_focus (GTK_WIDGET (self->pinned_box), direction) ||
           gtk_widget_child_focus (GTK_WIDGET (self->box), direction);

  is_rtl = gtk_widget_get_direction (widget) == GTK_TEXT_DIR_RTL;
  start = is_rtl ? GTK_DIR_RIGHT : GTK_DIR_LEFT;
  end = is_rtl ? GTK_DIR_LEFT : GTK_DIR_RIGHT;

  if (direction == start) {
    if (hdy_tab_view_select_previous_page (self->view))
      return GDK_EVENT_STOP;

    return gtk_widget_keynav_failed (widget, direction);
  }

  if (direction == end) {
    if (hdy_tab_view_select_next_page (self->view))
      return GDK_EVENT_STOP;

    return gtk_widget_keynav_failed (widget, direction);
  }

  return GDK_EVENT_PROPAGATE;
}

static void
hdy_tab_bar_size_allocate (GtkWidget     *widget,
                           GtkAllocation *allocation)
{
  HdyTabBar *self = HDY_TAB_BAR (widget);

  /* On RTL, the adjustment value is modified and will interfere with animations */
  hdy_tab_box_set_block_scrolling (self->box, TRUE);

  GTK_WIDGET_CLASS (hdy_tab_bar_parent_class)->size_allocate (widget,
                                                              allocation);

  hdy_tab_box_set_block_scrolling (self->box, FALSE);
}

static void
hdy_tab_bar_forall (GtkContainer *container,
                    gboolean      include_internals,
                    GtkCallback   callback,
                    gpointer      callback_data)
{
  HdyTabBar *self = HDY_TAB_BAR (container);
  GtkWidget *start, *end;

  if (include_internals) {
    GTK_CONTAINER_CLASS (hdy_tab_bar_parent_class)->forall (container,
                                                            include_internals,
                                                            callback,
                                                            callback_data);

    return;
  }

  start = hdy_tab_bar_get_start_action_widget (self);
  end = hdy_tab_bar_get_end_action_widget (self);

  if (start)
    callback (start, callback_data);

  if (end)
    callback (end, callback_data);
}

static void
hdy_tab_bar_dispose (GObject *object)
{
  HdyTabBar *self = HDY_TAB_BAR (object);

  hdy_tab_bar_set_view (self, NULL);

  G_OBJECT_CLASS (hdy_tab_bar_parent_class)->dispose (object);
}

static void
hdy_tab_bar_get_property (GObject    *object,
                          guint       prop_id,
                          GValue     *value,
                          GParamSpec *pspec)
{
  HdyTabBar *self = HDY_TAB_BAR (object);

  switch (prop_id) {
  case PROP_VIEW:
    g_value_set_object (value, hdy_tab_bar_get_view (self));
    break;

  case PROP_START_ACTION_WIDGET:
    g_value_set_object (value, hdy_tab_bar_get_start_action_widget (self));
    break;

  case PROP_END_ACTION_WIDGET:
    g_value_set_object (value, hdy_tab_bar_get_end_action_widget (self));
    break;

  case PROP_AUTOHIDE:
    g_value_set_boolean (value, hdy_tab_bar_get_autohide (self));
    break;

  case PROP_TABS_REVEALED:
    g_value_set_boolean (value, hdy_tab_bar_get_tabs_revealed (self));
    break;

  case PROP_EXPAND_TABS:
    g_value_set_boolean (value, hdy_tab_bar_get_expand_tabs (self));
    break;

  case PROP_INVERTED:
    g_value_set_boolean (value, hdy_tab_bar_get_inverted (self));
    break;

  case PROP_EXTRA_DRAG_DEST_TARGETS:
    g_value_set_boxed (value, hdy_tab_bar_get_extra_drag_dest_targets (self));
    break;

  case PROP_IS_OVERFLOWING:
    g_value_set_boolean (value, hdy_tab_bar_get_is_overflowing (self));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_tab_bar_set_property (GObject      *object,
                          guint         prop_id,
                          const GValue *value,
                          GParamSpec   *pspec)
{
  HdyTabBar *self = HDY_TAB_BAR (object);

  switch (prop_id) {
  case PROP_VIEW:
    hdy_tab_bar_set_view (self, g_value_get_object (value));
    break;

  case PROP_START_ACTION_WIDGET:
    hdy_tab_bar_set_start_action_widget (self, g_value_get_object (value));
    break;

  case PROP_END_ACTION_WIDGET:
    hdy_tab_bar_set_end_action_widget (self, g_value_get_object (value));
    break;

  case PROP_AUTOHIDE:
    hdy_tab_bar_set_autohide (self, g_value_get_boolean (value));
    break;

  case PROP_EXPAND_TABS:
    hdy_tab_bar_set_expand_tabs (self, g_value_get_boolean (value));
    break;

  case PROP_INVERTED:
    hdy_tab_bar_set_inverted (self, g_value_get_boolean (value));
    break;

  case PROP_EXTRA_DRAG_DEST_TARGETS:
    hdy_tab_bar_set_extra_drag_dest_targets (self, g_value_get_boxed (value));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_tab_bar_class_init (HdyTabBarClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);
  GtkContainerClass *container_class = GTK_CONTAINER_CLASS (klass);

  object_class->dispose = hdy_tab_bar_dispose;
  object_class->get_property = hdy_tab_bar_get_property;
  object_class->set_property = hdy_tab_bar_set_property;

  widget_class->destroy = hdy_tab_bar_destroy;
  widget_class->focus = hdy_tab_bar_focus;
  widget_class->size_allocate = hdy_tab_bar_size_allocate;

  container_class->forall = hdy_tab_bar_forall;

  /**
   * HdyTabBar:view:
   *
   * The #HdyTabView the tab bar controls.
   *
   * Since: 1.2
   */
  props[PROP_VIEW] =
    g_param_spec_object ("view",
                         _("View"),
                         _("The view the tab bar controls."),
                         HDY_TYPE_TAB_VIEW,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabBar:start-action-widget:
   *
   * The widget shown before the tabs.
   *
   * Since: 1.2
   */
  props[PROP_START_ACTION_WIDGET] =
    g_param_spec_object ("start-action-widget",
                         _("Start action widget"),
                         _("The widget shown before the tabs"),
                         GTK_TYPE_WIDGET,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabBar:end-action-widget:
   *
   * The widget shown after the tabs.
   *
   * Since: 1.2
   */
  props[PROP_END_ACTION_WIDGET] =
    g_param_spec_object ("end-action-widget",
                         _("End action widget"),
                         _("The widget shown after the tabs"),
                         GTK_TYPE_WIDGET,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabBar:autohide:
   *
   * Whether tabs automatically hide.
   *
   * If set to %TRUE, the tab bar disappears when the associated #HdyTabView
   * has 0 or 1 tab, no pinned tabs, and no tab is being transferred.
   *
   * See #HdyTabBar:tabs-revealed.
   *
   * Since: 1.2
   */
  props[PROP_AUTOHIDE] =
    g_param_spec_boolean ("autohide",
                          _("Autohide"),
                          _("Whether the tabs automatically hide"),
                          TRUE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabBar:tabs-revealed:
   *
   * Whether tabs are currently revealed.
   *
   * See HdyTabBar:autohide.
   *
   * Since: 1.2
   */
  props[PROP_TABS_REVEALED] =
    g_param_spec_boolean ("tabs-revealed",
                          _("Tabs revealed"),
                          _("Whether the tabs are currently revealed"),
                          FALSE,
                          G_PARAM_READABLE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabBar:expand-tabs:
   *
   * Whether tabs should expand.
   *
   * If set to %TRUE, the tabs will always vary width filling the whole width
   * when possible, otherwise tabs will always have the minimum possible size.
   *
   * Since: 1.2
   */
  props[PROP_EXPAND_TABS] =
    g_param_spec_boolean ("expand-tabs",
                          _("Expand tabs"),
                          _("Whether tabs expand to full width"),
                          TRUE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabBar:inverted:
   *
   * Whether tabs use inverted layout.
   *
   * If set to %TRUE, non-pinned tabs will have the close button at the
   * beginning and the indicator at the end rather than the opposite.
   *
   * Since: 1.2
   */
  props[PROP_INVERTED] =
    g_param_spec_boolean ("inverted",
                          _("Inverted"),
                          _("Whether tabs use inverted layout"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabBar:extra-drag-dest-targets:
   *
   * Extra drag destination targets.
   *
   * Allows to drag arbitrary content onto tabs, for example URLs in a web
   * browser.
   *
   * If a tab is hovered for a certain period of time while dragging the
   * content, it will be automatically selected.
   *
   * After content is dropped, the #HdyTabBar::extra-drag-data-received signal
   * can be used to retrieve and process the drag data.
   *
   * Since: 1.2
   */
  props[PROP_EXTRA_DRAG_DEST_TARGETS] =
    g_param_spec_boxed ("extra-drag-dest-targets",
                        _("Extra drag destination targets"),
                        _("Extra drag destination targets"),
                        GTK_TYPE_TARGET_LIST,
                        G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabBar:is-overflowing:
   *
   * Whether the tab bar is overflowing.
   *
   * If set to %TRUE, all tabs cannot be displayed at once and require
   * scrolling.
   *
   * Since: 1.2
   */
  props[PROP_IS_OVERFLOWING] =
    g_param_spec_boolean ("is-overflowing",
                          _("Is overflowing"),
                          _("Whether the tab bar is overflowing"),
                          FALSE,
                          G_PARAM_READABLE);

  g_object_class_install_properties (object_class, LAST_PROP, props);

  /**
   * HdyTabBar::extra-drag-data-received:
   * @self: a #HdyTabBar
   * @page: the #HdyTabPage matching the tab the content was dropped onto
   * @context: the drag context
   * @data: the received data
   * @info: the info that has been registered with the target in the #GtkTargetList
   * @time: the timestamp at which the data was received
   *
   * This signal is emitted when content allowed via
   * #HdyTabBar:extra-drag-dest-targets is dropped onto a tab.
   *
   * See #GtkWidget::drag-data-received.
   *
   * Since: 1.2
   */
  signals[SIGNAL_EXTRA_DRAG_DATA_RECEIVED] =
    g_signal_new ("extra-drag-data-received",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  0,
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  5,
                  HDY_TYPE_TAB_PAGE,
                  GDK_TYPE_DRAG_CONTEXT,
                  GTK_TYPE_SELECTION_DATA,
                  G_TYPE_UINT,
                  G_TYPE_UINT);

  gtk_widget_class_set_template_from_resource (widget_class,
                                               "/sm/puri/handy/ui/hdy-tab-bar.ui");
  gtk_widget_class_bind_template_child (widget_class, HdyTabBar, revealer);
  gtk_widget_class_bind_template_child (widget_class, HdyTabBar, pinned_box);
  gtk_widget_class_bind_template_child (widget_class, HdyTabBar, box);
  gtk_widget_class_bind_template_child (widget_class, HdyTabBar, viewport);
  gtk_widget_class_bind_template_child (widget_class, HdyTabBar, pinned_viewport);
  gtk_widget_class_bind_template_child (widget_class, HdyTabBar, scrolled_window);
  gtk_widget_class_bind_template_child (widget_class, HdyTabBar, pinned_scrolled_window);
  gtk_widget_class_bind_template_child (widget_class, HdyTabBar, start_action_bin);
  gtk_widget_class_bind_template_child (widget_class, HdyTabBar, end_action_bin);
  gtk_widget_class_bind_template_callback (widget_class, notify_needs_attention_cb);
  gtk_widget_class_bind_template_callback (widget_class, notify_needs_attention_pinned_cb);
  gtk_widget_class_bind_template_callback (widget_class, notify_resize_frozen_cb);
  gtk_widget_class_bind_template_callback (widget_class, stop_kinetic_scrolling_cb);
  gtk_widget_class_bind_template_callback (widget_class, extra_drag_data_received_cb);

  gtk_widget_class_set_css_name (widget_class, "tabbar");
}

static void
hdy_tab_bar_init (HdyTabBar *self)
{
  GtkAdjustment *adj;

  self->autohide = TRUE;

  g_type_ensure (HDY_TYPE_TAB_BOX);

  gtk_widget_init_template (GTK_WIDGET (self));

  adj = gtk_scrolled_window_get_hadjustment (self->scrolled_window);
  hdy_tab_box_set_adjustment (self->box, adj);
  g_signal_connect_object (adj, "changed", G_CALLBACK (update_is_overflowing),
                           self, G_CONNECT_SWAPPED);

  adj = gtk_scrolled_window_get_hadjustment (self->pinned_scrolled_window);
  hdy_tab_box_set_adjustment (self->pinned_box, adj);
  g_signal_connect_object (adj, "changed", G_CALLBACK (update_is_overflowing),
                           self, G_CONNECT_SWAPPED);

  /* HdyTabBox scrolls on focus itself, and does it better than GtkViewport */
  gtk_container_set_focus_hadjustment (GTK_CONTAINER (self->viewport), NULL);
  gtk_container_set_focus_hadjustment (GTK_CONTAINER (self->pinned_viewport), NULL);
}

static void
hdy_tab_bar_buildable_add_child (GtkBuildable *buildable,
                                 GtkBuilder   *builder,
                                 GObject      *child,
                                 const gchar  *type)
{
  HdyTabBar *self = HDY_TAB_BAR (buildable);

  if (!self->revealer) {
    gtk_container_add (GTK_CONTAINER (self), GTK_WIDGET (child));

    return;
  }

  if (!type || !g_strcmp0 (type, "start"))
    hdy_tab_bar_set_start_action_widget (self, GTK_WIDGET (child));
  else if (!g_strcmp0 (type, "end"))
    hdy_tab_bar_set_end_action_widget (self, GTK_WIDGET (child));
  else
    GTK_BUILDER_WARN_INVALID_CHILD_TYPE (HDY_TAB_BAR (self), type);
}

static void
hdy_tab_bar_buildable_init (GtkBuildableIface *iface)
{
  iface->add_child = hdy_tab_bar_buildable_add_child;
}

gboolean
hdy_tab_bar_tabs_have_visible_focus (HdyTabBar *self)
{
  GtkWidget *pinned_focus_child, *scroll_focus_child;

  g_return_val_if_fail (HDY_IS_TAB_BAR (self), FALSE);

  pinned_focus_child = gtk_container_get_focus_child (GTK_CONTAINER (self->pinned_box));
  scroll_focus_child = gtk_container_get_focus_child (GTK_CONTAINER (self->box));

  if (pinned_focus_child && gtk_widget_has_visible_focus (pinned_focus_child))
    return TRUE;

  if (scroll_focus_child && gtk_widget_has_visible_focus (scroll_focus_child))
    return TRUE;

  return FALSE;
}

/**
 * hdy_tab_bar_new:
 *
 * Creates a new #HdyTabBar widget.
 *
 * Returns: a new #HdyTabBar
 *
 * Since: 1.2
 */
HdyTabBar *
hdy_tab_bar_new (void)
{
  return g_object_new (HDY_TYPE_TAB_BAR, NULL);
}

/**
 * hdy_tab_bar_get_view:
 * @self: a #HdyTabBar
 *
 * Gets the #HdyTabView @self controls.
 *
 * Returns: (transfer none) (nullable): the #HdyTabView @self controls
 *
 * Since: 1.2
 */
HdyTabView *
hdy_tab_bar_get_view (HdyTabBar *self)
{
  g_return_val_if_fail (HDY_IS_TAB_BAR (self), NULL);

  return self->view;
}

/**
 * hdy_tab_bar_set_view:
 * @self: a #HdyTabBar
 * @view: (nullable): a #HdyTabView
 *
 * Sets the #HdyTabView @self controls.
 *
 * Since: 1.2
 */
void
hdy_tab_bar_set_view (HdyTabBar  *self,
                      HdyTabView *view)
{
  g_return_if_fail (HDY_IS_TAB_BAR (self));
  g_return_if_fail (HDY_IS_TAB_VIEW (view) || view == NULL);

  if (self->view == view)
    return;

  if (self->view) {
    gint i, n;

    g_signal_handlers_disconnect_by_func (self->view, update_autohide_cb, self);
    g_signal_handlers_disconnect_by_func (self->view, notify_selected_page_cb, self);
    g_signal_handlers_disconnect_by_func (self->view, page_attached_cb, self);
    g_signal_handlers_disconnect_by_func (self->view, page_detached_cb, self);
    g_signal_handlers_disconnect_by_func (self->view, view_destroy_cb, self);

    n = hdy_tab_view_get_n_pages (self->view);

    for (i = 0; i < n; i++)
      page_detached_cb (self, hdy_tab_view_get_nth_page (self->view, i), i);

    hdy_tab_box_set_view (self->pinned_box, NULL);
    hdy_tab_box_set_view (self->box, NULL);
  }

  g_set_object (&self->view, view);

  if (self->view) {
    gint i, n;

    hdy_tab_box_set_view (self->pinned_box, view);
    hdy_tab_box_set_view (self->box, view);

    g_signal_connect_object (self->view, "notify::is-transferring-page",
                             G_CALLBACK (update_autohide_cb), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->view, "notify::n-pages",
                             G_CALLBACK (update_autohide_cb), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->view, "notify::n-pinned-pages",
                             G_CALLBACK (update_autohide_cb), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->view, "notify::selected-page",
                             G_CALLBACK (notify_selected_page_cb), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->view, "page-attached",
                             G_CALLBACK (page_attached_cb), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->view, "page-detached",
                             G_CALLBACK (page_detached_cb), self,
                             G_CONNECT_SWAPPED);
    g_signal_connect_object (self->view, "destroy",
                             G_CALLBACK (view_destroy_cb), self,
                             G_CONNECT_SWAPPED);

    n = hdy_tab_view_get_n_pages (self->view);

    for (i = 0; i < n; i++)
      page_attached_cb (self, hdy_tab_view_get_nth_page (self->view, i), i);
  }

  update_autohide_cb (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_VIEW]);
}

/**
 * hdy_tab_bar_get_start_action_widget:
 * @self: a #HdyTabBar
 *
 * Gets the widget shown before the tabs.
 *
 * Returns: (transfer none) (nullable): the widget shown before the tabs, or %NULL
 *
 * Since: 1.2
 */
GtkWidget *
hdy_tab_bar_get_start_action_widget (HdyTabBar *self)
{
  g_return_val_if_fail (HDY_IS_TAB_BAR (self), NULL);

  return self->start_action_bin ? gtk_bin_get_child (self->start_action_bin) : NULL;
}

/**
 * hdy_tab_bar_set_start_action_widget:
 * @self: a #HdyTabBar
 * @widget: (transfer none) (nullable): the widget to show before the tabs, or %NULL
 *
 * Sets the widget to show before the tabs.
 *
 * Since: 1.2
 */
void
hdy_tab_bar_set_start_action_widget (HdyTabBar *self,
                                     GtkWidget *widget)
{
  GtkWidget *old_widget;

  g_return_if_fail (HDY_IS_TAB_BAR (self));
  g_return_if_fail (GTK_IS_WIDGET (widget) || widget == NULL);

  old_widget = gtk_bin_get_child (self->start_action_bin);

  if (old_widget == widget)
    return;

  if (old_widget)
    gtk_container_remove (GTK_CONTAINER (self->start_action_bin), old_widget);

  if (widget)
    gtk_container_add (GTK_CONTAINER (self->start_action_bin), widget);

  gtk_widget_set_visible (GTK_WIDGET (self->start_action_bin), widget != NULL);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_START_ACTION_WIDGET]);
}

/**
 * hdy_tab_bar_get_end_action_widget:
 * @self: a #HdyTabBar
 *
 * Gets the widget shown after the tabs.
 *
 * Returns: (transfer none) (nullable): the widget shown after the tabs, or %NULL
 *
 * Since: 1.2
 */
GtkWidget *
hdy_tab_bar_get_end_action_widget (HdyTabBar *self)
{
  g_return_val_if_fail (HDY_IS_TAB_BAR (self), NULL);

  return self->end_action_bin ? gtk_bin_get_child (self->end_action_bin) : NULL;
}

/**
 * hdy_tab_bar_set_end_action_widget:
 * @self: a #HdyTabBar
 * @widget: (transfer none) (nullable): the widget to show after the tabs, or %NULL
 *
 * Sets the widget to show after the tabs.
 *
 * Since: 1.2
 */
void
hdy_tab_bar_set_end_action_widget (HdyTabBar *self,
                                   GtkWidget *widget)
{
  GtkWidget *old_widget;

  g_return_if_fail (HDY_IS_TAB_BAR (self));
  g_return_if_fail (GTK_IS_WIDGET (widget) || widget == NULL);

  old_widget = gtk_bin_get_child (self->end_action_bin);

  if (old_widget == widget)
    return;

  if (old_widget)
    gtk_container_remove (GTK_CONTAINER (self->end_action_bin), old_widget);

  if (widget)
    gtk_container_add (GTK_CONTAINER (self->end_action_bin), widget);

  gtk_widget_set_visible (GTK_WIDGET (self->end_action_bin), widget != NULL);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_END_ACTION_WIDGET]);
}

/**
 * hdy_tab_bar_get_autohide:
 * @self: a #HdyTabBar
 *
 * Gets whether the tabs automatically hide, see hdy_tab_bar_set_autohide().
 *
 * Returns: whether the tabs automatically hide
 *
 * Since: 1.2
 */
gboolean
hdy_tab_bar_get_autohide (HdyTabBar *self)
{
  g_return_val_if_fail (HDY_IS_TAB_BAR (self), FALSE);

  return self->autohide;
}

/**
 * hdy_tab_bar_set_autohide:
 * @self: a #HdyTabBar
 * @autohide: whether the tabs automatically hide
 *
 * Sets whether the tabs automatically hide.
 *
 * If @autohide is %TRUE, the tab bar disappears when the associated #HdyTabView
 * has 0 or 1 tab, no pinned tabs, and no tab is being transferred.
 *
 * Autohide is enabled by default.
 *
 * See #HdyTabBar:tabs-revealed.
 *
 * Since: 1.2
 */
void
hdy_tab_bar_set_autohide (HdyTabBar *self,
                          gboolean   autohide)
{
  g_return_if_fail (HDY_IS_TAB_BAR (self));

  autohide = !!autohide;

  if (autohide == self->autohide)
    return;

  self->autohide = autohide;

  update_autohide_cb (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_AUTOHIDE]);
}

/**
 * hdy_tab_bar_get_tabs_revealed:
 * @self: a #HdyTabBar
 *
 * Gets the value of the #HdyTabBar:tabs-revealed property.
 *
 * Returns: whether the tabs are current revealed
 *
 * Since: 1.2
 */
gboolean
hdy_tab_bar_get_tabs_revealed (HdyTabBar *self)
{
  g_return_val_if_fail (HDY_IS_TAB_BAR (self), FALSE);

  return gtk_revealer_get_reveal_child (self->revealer);
}

/**
 * hdy_tab_bar_get_expand_tabs:
 * @self: a #HdyTabBar
 *
 * Gets whether tabs should expand, see hdy_tab_bar_set_expand_tabs().
 *
 * Returns: whether tabs should expand
 *
 * Since: 1.2
 */
gboolean
hdy_tab_bar_get_expand_tabs (HdyTabBar *self)
{
  g_return_val_if_fail (HDY_IS_TAB_BAR (self), FALSE);

  return hdy_tab_box_get_expand_tabs (self->box);
}

/**
 * hdy_tab_bar_set_expand_tabs:
 * @self: a #HdyTabBar
 * @expand_tabs: whether to expand tabs
 *
 * Sets whether tabs should expand.
 *
 * If @expand_tabs is %TRUE, the tabs will always vary width filling the whole
 * width when possible, otherwise tabs will always have the minimum possible
 * size.
 *
 * Expand is enabled by default.
 *
 * Since: 1.2
 */
void
hdy_tab_bar_set_expand_tabs (HdyTabBar *self,
                             gboolean   expand_tabs)
{
  g_return_if_fail (HDY_IS_TAB_BAR (self));

  expand_tabs = !!expand_tabs;

  if (hdy_tab_bar_get_expand_tabs (self) == expand_tabs)
    return;

  hdy_tab_box_set_expand_tabs (self->box, expand_tabs);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_EXPAND_TABS]);
}

/**
 * hdy_tab_bar_get_inverted:
 * @self: a #HdyTabBar
 *
 * Gets whether tabs use inverted layout, see hdy_tab_bar_set_inverted().
 *
 * Returns: whether tabs use inverted layout
 *
 * Since: 1.2
 */
gboolean
hdy_tab_bar_get_inverted (HdyTabBar *self)
{
  g_return_val_if_fail (HDY_IS_TAB_BAR (self), FALSE);

  return hdy_tab_box_get_inverted (self->box);
}

/**
 * hdy_tab_bar_set_inverted:
 * @self: a #HdyTabBar
 * @inverted: whether tabs use inverted layout
 *
 * Sets whether tabs tabs use inverted layout.
 *
 * If @inverted is %TRUE, non-pinned tabs will have the close button at the
 * beginning and the indicator at the end rather than the opposite.
 *
 * Since: 1.2
 */
void
hdy_tab_bar_set_inverted (HdyTabBar *self,
                          gboolean   inverted)
{
  g_return_if_fail (HDY_IS_TAB_BAR (self));

  inverted = !!inverted;

  if (hdy_tab_bar_get_inverted (self) == inverted)
    return;

  hdy_tab_box_set_inverted (self->box, inverted);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_INVERTED]);
}

/**
 * hdy_tab_bar_get_extra_drag_dest_targets:
 * @self: a #HdyTabBar
 *
 * Gets extra drag destination targets, see
 * hdy_tab_bar_set_extra_drag_dest_targets().
 *
 * Returns: (transfer none) (nullable): extra drag targets, or %NULL
 *
 * Since: 1.2
 */
GtkTargetList *
hdy_tab_bar_get_extra_drag_dest_targets (HdyTabBar *self)
{
  g_return_val_if_fail (HDY_IS_TAB_BAR (self), NULL);

  return self->extra_drag_dest_targets;
}

/**
 * hdy_tab_bar_set_extra_drag_dest_targets:
 * @self: a #HdyTabBar
 * @extra_drag_dest_targets: (transfer none) (nullable): extra drag targets, or %NULL
 *
 * Sets extra drag destination targets.
 *
 * This allows to drag arbitrary content onto tabs, for example URLs in a web
 * browser.
 *
 * If a tab is hovered for a certain period of time while dragging the content,
 * it will be automatically selected.
 *
 * After content is dropped, the #HdyTabBar::extra-drag-data-received signal can
 * be used to retrieve and process the drag data.
 *
 * Since: 1.2
 */
void
hdy_tab_bar_set_extra_drag_dest_targets (HdyTabBar     *self,
                                         GtkTargetList *extra_drag_dest_targets)
{
  g_return_if_fail (HDY_IS_TAB_BAR (self));

  if (extra_drag_dest_targets == self->extra_drag_dest_targets)
    return;

  if (self->extra_drag_dest_targets)
    gtk_target_list_unref (self->extra_drag_dest_targets);

  if (extra_drag_dest_targets)
    gtk_target_list_ref (extra_drag_dest_targets);

  self->extra_drag_dest_targets = extra_drag_dest_targets;

  hdy_tab_box_set_extra_drag_dest_targets (self->box, extra_drag_dest_targets);
  hdy_tab_box_set_extra_drag_dest_targets (self->pinned_box, extra_drag_dest_targets);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_EXTRA_DRAG_DEST_TARGETS]);
}

/**
 * hdy_tab_bar_get_is_overflowing:
 * @self: a #HdyTabBar
 *
 * Gets whether @self is overflowing.
 *
 * Returns: whether @self is overflowing
 *
 * Since: 1.2
 */
gboolean
hdy_tab_bar_get_is_overflowing (HdyTabBar *self)
{
  g_return_val_if_fail (HDY_IS_TAB_BAR (self), FALSE);

  return self->is_overflowing;
}
