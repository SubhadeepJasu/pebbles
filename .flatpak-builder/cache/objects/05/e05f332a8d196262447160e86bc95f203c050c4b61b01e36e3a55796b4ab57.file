/*
 * Copyright (C) 2020 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1+
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#include "config.h"
#include <glib/gi18n-lib.h>

#include "hdy-tab-view-private.h"

/* FIXME replace with groups */
static GSList *tab_view_list;

static const GtkTargetEntry dst_targets [] = {
  { "HDY_TAB", GTK_TARGET_SAME_APP, 0 },
};

/**
 * SECTION:hdy-tab-view
 * @short_description: A dynamic tabbed container
 * @title: HdyTabView
 * @See_also: #HdyTabBar
 *
 * #HdyTabView is a container which shows one child at a time. While it provides
 * keyboard shortcuts for switching between pages, it does not provide a visible
 * tab bar and relies on external widgets for that, such as #HdyTabBar.
 *
 * #HdyTabView maintains a #HdyTabPage object for each page,which holds
 * additional per-page properties. You can obtain the #HdyTabPage for a page
 * with hdy_tab_view_get_page(), and as return value for hdy_tab_view_append()
 * and other functions for adding children.
 *
 * #HdyTabView only aims to be useful for dynamic tabs in multi-window
 * document-based applications, such as web browsers, file managers, text
 * editors or terminals. It does not aim to replace #GtkNotebook for use cases
 * such as tabbed dialogs.
 *
 * As such, it does not support disabling page reordering or detaching, or
 * adding children via #GtkBuilder.
 *
 * # CSS nodes
 *
 * #HdyTabView has a main CSS node with the name tabview.
 *
 * It contains the subnode overlay, which contains subnodes stack and widget.
 * The stack subnode contains the added pages.
 *
 * |[<!-- language="plain" -->
 * tabview
 * ╰── overlay
 *     ├── stack
 *     │   ╰── [ Children ]
 *     ╰── widget
 * ]|
 *
 * Since: 1.2
 */

struct _HdyTabPage
{
  GObject parent_instance;

  GtkWidget *child;
  HdyTabPage *parent;
  gboolean selected;
  gboolean pinned;
  gchar *title;
  gchar *tooltip;
  GIcon *icon;
  gboolean loading;
  GIcon *indicator_icon;
  gboolean indicator_activatable;
  gboolean needs_attention;

  gboolean closing;
};

G_DEFINE_TYPE (HdyTabPage, hdy_tab_page, G_TYPE_OBJECT)

enum {
  PAGE_PROP_0,
  PAGE_PROP_CHILD,
  PAGE_PROP_PARENT,
  PAGE_PROP_SELECTED,
  PAGE_PROP_PINNED,
  PAGE_PROP_TITLE,
  PAGE_PROP_TOOLTIP,
  PAGE_PROP_ICON,
  PAGE_PROP_LOADING,
  PAGE_PROP_INDICATOR_ICON,
  PAGE_PROP_INDICATOR_ACTIVATABLE,
  PAGE_PROP_NEEDS_ATTENTION,
  LAST_PAGE_PROP
};

static GParamSpec *page_props[LAST_PAGE_PROP];

struct _HdyTabView
{
  GtkBin parent_instance;

  GtkStack *stack;
  GListStore *pages;

  gint n_pages;
  gint n_pinned_pages;
  HdyTabPage *selected_page;
  GIcon *default_icon;
  GMenuModel *menu_model;

  gint transfer_count;
  GtkWidget *shortcut_widget;
};

G_DEFINE_TYPE (HdyTabView, hdy_tab_view, GTK_TYPE_BIN)

enum {
  PROP_0,
  PROP_N_PAGES,
  PROP_N_PINNED_PAGES,
  PROP_IS_TRANSFERRING_PAGE,
  PROP_SELECTED_PAGE,
  PROP_DEFAULT_ICON,
  PROP_MENU_MODEL,
  PROP_SHORTCUT_WIDGET,
  LAST_PROP
};

static GParamSpec *props[LAST_PROP];

enum {
  SIGNAL_PAGE_ATTACHED,
  SIGNAL_PAGE_DETACHED,
  SIGNAL_PAGE_REORDERED,
  SIGNAL_CLOSE_PAGE,
  SIGNAL_SETUP_MENU,
  SIGNAL_CREATE_WINDOW,
  SIGNAL_INDICATOR_ACTIVATED,
  SIGNAL_LAST_SIGNAL,
};

static guint signals[SIGNAL_LAST_SIGNAL];

static void
set_page_selected (HdyTabPage *self,
                   gboolean    selected)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));

  selected = !!selected;

  if (self->selected == selected)
    return;

  self->selected = selected;

  g_object_notify_by_pspec (G_OBJECT (self), page_props[PAGE_PROP_SELECTED]);
}

static void
set_page_pinned (HdyTabPage *self,
                 gboolean    pinned)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));

  pinned = !!pinned;

  if (self->pinned == pinned)
    return;

  self->pinned = pinned;

  g_object_notify_by_pspec (G_OBJECT (self), page_props[PAGE_PROP_PINNED]);
}

static void set_page_parent (HdyTabPage *self,
                             HdyTabPage *parent);

static void
page_parent_notify_cb (HdyTabPage *self)
{
  HdyTabPage *grandparent = hdy_tab_page_get_parent (self->parent);

  self->parent = NULL;

  if (grandparent)
    set_page_parent (self, grandparent);
  else
    g_object_notify_by_pspec (G_OBJECT (self), props[PAGE_PROP_PARENT]);
}

static void
set_page_parent (HdyTabPage *self,
                 HdyTabPage *parent)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (parent) || parent == NULL);

  if (self->parent == parent)
    return;

  if (self->parent)
    g_object_weak_unref (G_OBJECT (self->parent),
                         (GWeakNotify) page_parent_notify_cb,
                         self);

  self->parent = parent;

  if (self->parent)
    g_object_weak_ref (G_OBJECT (self->parent),
                       (GWeakNotify) page_parent_notify_cb,
                       self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PAGE_PROP_PARENT]);
}

static void
hdy_tab_page_dispose (GObject *object)
{
  HdyTabPage *self = HDY_TAB_PAGE (object);

  set_page_parent (self, NULL);

  G_OBJECT_CLASS (hdy_tab_page_parent_class)->dispose (object);
}

static void
hdy_tab_page_finalize (GObject *object)
{
  HdyTabPage *self = (HdyTabPage *)object;

  g_clear_object (&self->child);
  g_clear_pointer (&self->title, g_free);
  g_clear_pointer (&self->tooltip, g_free);
  g_clear_object (&self->icon);
  g_clear_object (&self->indicator_icon);

  G_OBJECT_CLASS (hdy_tab_page_parent_class)->finalize (object);
}

static void
hdy_tab_page_get_property (GObject    *object,
                           guint       prop_id,
                           GValue     *value,
                           GParamSpec *pspec)
{
  HdyTabPage *self = HDY_TAB_PAGE (object);

  switch (prop_id) {
  case PAGE_PROP_CHILD:
    g_value_set_object (value, hdy_tab_page_get_child (self));
    break;

  case PAGE_PROP_PARENT:
    g_value_set_object (value, hdy_tab_page_get_parent (self));
    break;

  case PAGE_PROP_SELECTED:
    g_value_set_boolean (value, hdy_tab_page_get_selected (self));
    break;

  case PAGE_PROP_PINNED:
    g_value_set_boolean (value, hdy_tab_page_get_pinned (self));
    break;

  case PAGE_PROP_TITLE:
    g_value_set_string (value, hdy_tab_page_get_title (self));
    break;

  case PAGE_PROP_TOOLTIP:
    g_value_set_string (value, hdy_tab_page_get_tooltip (self));
    break;

  case PAGE_PROP_ICON:
    g_value_set_object (value, hdy_tab_page_get_icon (self));
    break;

  case PAGE_PROP_LOADING:
    g_value_set_boolean (value, hdy_tab_page_get_loading (self));
    break;

  case PAGE_PROP_INDICATOR_ICON:
    g_value_set_object (value, hdy_tab_page_get_indicator_icon (self));
    break;

  case PAGE_PROP_INDICATOR_ACTIVATABLE:
    g_value_set_boolean (value, hdy_tab_page_get_indicator_activatable (self));
    break;

  case PAGE_PROP_NEEDS_ATTENTION:
    g_value_set_boolean (value, hdy_tab_page_get_needs_attention (self));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_tab_page_set_property (GObject      *object,
                           guint         prop_id,
                           const GValue *value,
                           GParamSpec   *pspec)
{
  HdyTabPage *self = HDY_TAB_PAGE (object);

  switch (prop_id) {
  case PAGE_PROP_CHILD:
    g_set_object (&self->child, g_value_get_object (value));
    break;

  case PAGE_PROP_PARENT:
    set_page_parent (self, g_value_get_object (value));
    break;

  case PAGE_PROP_TITLE:
    hdy_tab_page_set_title (self, g_value_get_string (value));
    break;

  case PAGE_PROP_TOOLTIP:
    hdy_tab_page_set_tooltip (self, g_value_get_string (value));
    break;

  case PAGE_PROP_ICON:
    hdy_tab_page_set_icon (self, g_value_get_object (value));
    break;

  case PAGE_PROP_LOADING:
    hdy_tab_page_set_loading (self, g_value_get_boolean (value));
    break;

  case PAGE_PROP_INDICATOR_ICON:
    hdy_tab_page_set_indicator_icon (self, g_value_get_object (value));
    break;

  case PAGE_PROP_INDICATOR_ACTIVATABLE:
    hdy_tab_page_set_indicator_activatable (self, g_value_get_boolean (value));
    break;

  case PAGE_PROP_NEEDS_ATTENTION:
    hdy_tab_page_set_needs_attention (self, g_value_get_boolean (value));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_tab_page_class_init (HdyTabPageClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);

  object_class->dispose = hdy_tab_page_dispose;
  object_class->finalize = hdy_tab_page_finalize;
  object_class->get_property = hdy_tab_page_get_property;
  object_class->set_property = hdy_tab_page_set_property;

  /**
   * HdyTabPage:child:
   *
   * The child of the page.
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_CHILD] =
    g_param_spec_object ("child",
                         _("Child"),
                         _("The child of the page"),
                         GTK_TYPE_WIDGET,
                         G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY);

  /**
   * HdyTabPage:parent:
   *
   * The parent page of the page.
   *
   * See hdy_tab_view_add_page() and hdy_tab_view_close_page().

   * Since: 1.2
   */
  page_props[PAGE_PROP_PARENT] =
    g_param_spec_object ("parent",
                         _("Parent"),
                         _("The parent page of the page"),
                         HDY_TYPE_TAB_PAGE,
                         G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabPage:selected:
   *
   * Whether the page is selected.
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_SELECTED] =
    g_param_spec_boolean ("selected",
                         _("Selected"),
                         _("Whether the page is selected"),
                         FALSE,
                         G_PARAM_READABLE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabPage:pinned:
   *
   * Whether the page is pinned. See hdy_tab_view_set_page_pinned().
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_PINNED] =
    g_param_spec_boolean ("pinned",
                         _("Pinned"),
                         _("Whether the page is pinned"),
                         FALSE,
                         G_PARAM_READABLE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabPage:title:
   *
   * The title of the page.
   *
   * #HdyTabBar will display it in the center of the tab unless it's pinned,
   * and will use it as a tooltip unless #HdyTabPage:tooltip is set.
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_TITLE] =
    g_param_spec_string ("title",
                         _("Title"),
                         _("The title of the page"),
                         NULL,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabPage:tooltip:
   *
   * The tooltip of the page, marked up with the Pango text markup language.
   *
   * If not set, #HdyTabBar will use #HdyTabPage:title as a tooltip instead.
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_TOOLTIP] =
    g_param_spec_string ("tooltip",
                         _("Tooltip"),
                         _("The tooltip of the page"),
                         NULL,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabPage:icon:
   *
   * The icon of the page, displayed next to the title.
   *
   * #HdyTabBar will not show the icon if #HdyTabPage:loading is set to %TRUE,
   * or if the page is pinned and #HdyTabPage:indicator-icon is set.
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_ICON] =
    g_param_spec_object ("icon",
                         _("Icon"),
                         _("The icon of the page"),
                         G_TYPE_ICON,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabPage:loading:
   *
   * Whether the page is loading.
   *
   * If set to %TRUE, #HdyTabBar will display a spinner in place of icon.
   *
   * If the page is pinned and #HdyTabPage:indicator-icon is set, the loading
   * status will not be visible.
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_LOADING] =
    g_param_spec_boolean ("loading",
                         _("Loading"),
                         _("Whether the page is loading"),
                         FALSE,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabPage:indicator-icon:
   *
   * An indicator icon for the page.
   *
   * A common use case is an audio or camera indicator in a web browser.
   *
   * #HdyTabPage will show it at the beginning of the tab, alongside icon
   * representing #HdyTabPage:icon or loading spinner.
   *
   * If the page is pinned, the indicator will be shown instead of icon or
   * spinner.
   *
   * If #HdyTabPage:indicator-activatable is set to %TRUE, the indicator icon
   * can act as a button.
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_INDICATOR_ICON] =
    g_param_spec_object ("indicator-icon",
                         _("Indicator icon"),
                         _("An indicator icon for the page"),
                         G_TYPE_ICON,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabPage:indicator-activatable:
   *
   * Whether the indicator icon is activatable.
   *
   * If set to %TRUE, #HdyTabView::indicator-activated will be emitted when
   * the indicator icon is clicked.
   *
   * If #HdyTabPage:indicator-icon is not set, does nothing.
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_INDICATOR_ACTIVATABLE] =
    g_param_spec_boolean ("indicator-activatable",
                         _("Indicator activatable"),
                         _("Whether the indicator icon is activatable"),
                         FALSE,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabPage:needs-attention:
   *
   * Whether the page needs attention.
   *
   * #HdyTabBar will display a glow under the tab representing the page if set
   * to %TRUE. If the tab is not visible, the corresponding edge of the tab bar
   * will be highlighted.
   *
   * Since: 1.2
   */
  page_props[PAGE_PROP_NEEDS_ATTENTION] =
    g_param_spec_boolean ("needs-attention",
                         _("Needs attention"),
                         _("Whether the page needs attention"),
                         FALSE,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  g_object_class_install_properties (object_class, LAST_PAGE_PROP, page_props);
}

static void
hdy_tab_page_init (HdyTabPage *self)
{
}

static gboolean
object_handled_accumulator (GSignalInvocationHint *ihint,
                            GValue                *return_accu,
                            const GValue          *handler_return,
                            gpointer               data)
{
  GObject *object = g_value_get_object (handler_return);

  g_value_set_object (return_accu, object);

  return !object;
}

static void
begin_transfer_for_group (HdyTabView *self)
{
  GSList *l;

  for (l = tab_view_list; l; l = l->next) {
    HdyTabView *view = l->data;

    view->transfer_count++;

    if (view->transfer_count == 1)
      g_object_notify_by_pspec (G_OBJECT (view), props[PROP_IS_TRANSFERRING_PAGE]);
  }
}

static void
end_transfer_for_group (HdyTabView *self)
{
  GSList *l;

  for (l = tab_view_list; l; l = l->next) {
    HdyTabView *view = l->data;

    view->transfer_count--;

    if (view->transfer_count == 0)
      g_object_notify_by_pspec (G_OBJECT (view), props[PROP_IS_TRANSFERRING_PAGE]);
  }
}

static void
set_n_pages (HdyTabView *self,
             gint        n_pages)
{
  if (n_pages == self->n_pages)
    return;

  self->n_pages = n_pages;

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_N_PAGES]);
}

static void
set_n_pinned_pages (HdyTabView *self,
                    gint        n_pinned_pages)
{
  if (n_pinned_pages == self->n_pinned_pages)
    return;

  self->n_pinned_pages = n_pinned_pages;

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_N_PINNED_PAGES]);
}

static inline gboolean
page_belongs_to_this_view (HdyTabView *self,
                           HdyTabPage *page)
{
  if (!page)
    return FALSE;

  return gtk_widget_get_parent (page->child) == GTK_WIDGET (self->stack);
}

static inline gboolean
is_descendant_of (HdyTabPage *page,
                  HdyTabPage *parent)
{
  while (page && page != parent)
    page = hdy_tab_page_get_parent (page);

  return page == parent;
}

static void
attach_page (HdyTabView *self,
             HdyTabPage *page,
             gint        position)
{
  GtkWidget *child = hdy_tab_page_get_child (page);
  HdyTabPage *parent;

  g_list_store_insert (self->pages, position, page);

  gtk_container_add (GTK_CONTAINER (self->stack), child);
  gtk_container_child_set (GTK_CONTAINER (self->stack), child,
                           "position", position,
                           NULL);

  g_object_freeze_notify (G_OBJECT (self));

  set_n_pages (self, self->n_pages + 1);

  if (hdy_tab_page_get_pinned (page))
    set_n_pinned_pages (self, self->n_pinned_pages + 1);

  g_object_thaw_notify (G_OBJECT (self));

  parent = hdy_tab_page_get_parent (page);

  if (parent && !page_belongs_to_this_view (self, parent))
    set_page_parent (page, NULL);

  g_signal_emit (self, signals[SIGNAL_PAGE_ATTACHED], 0, page, position);
}

static void
select_previous_page (HdyTabView *self,
                      HdyTabPage *page)
{
  gint pos = hdy_tab_view_get_page_position (self, page);
  HdyTabPage *parent;

  if (page != self->selected_page)
    return;

  parent = hdy_tab_page_get_parent (page);

  if (parent && pos > 0) {
    HdyTabPage *prev_page = hdy_tab_view_get_nth_page (self, pos - 1);

    /* This usually means we opened a few pages from the same page in a row, or
     * the previous page is the parent. Switch there. */
    if (is_descendant_of (prev_page, parent)) {
      hdy_tab_view_set_selected_page (self, prev_page);

      return;
    }

    /* Pinned pages are special in that opening a page from a pinned parent
     * will place it not directly after the parent, but after the last pinned
     * page. This means that if we're closing the first non-pinned page, we need
     * to jump to the parent directly instead of the previous page which might
     * be different. */
    if (hdy_tab_page_get_pinned (prev_page) &&
        hdy_tab_page_get_pinned (parent)) {
      hdy_tab_view_set_selected_page (self, parent);

      return;
    }
  }

  if (hdy_tab_view_select_next_page (self))
    return;

  hdy_tab_view_select_previous_page (self);
}

static void
detach_page (HdyTabView *self,
             HdyTabPage *page)
{
  gint pos = hdy_tab_view_get_page_position (self, page);
  GtkWidget *child;

  select_previous_page (self, page);

  child = hdy_tab_page_get_child (page);

  g_object_ref (page);
  g_object_ref (child);

  g_list_store_remove (self->pages, pos);

  g_object_freeze_notify (G_OBJECT (self));

  set_n_pages (self, self->n_pages - 1);

  if (hdy_tab_page_get_pinned (page))
    set_n_pinned_pages (self, self->n_pinned_pages - 1);

  if (self->n_pages == 0)
    hdy_tab_view_set_selected_page (self, NULL);

  g_object_thaw_notify (G_OBJECT (self));

  gtk_container_remove (GTK_CONTAINER (self->stack), child);

  g_signal_emit (self, signals[SIGNAL_PAGE_DETACHED], 0, page, pos);

  g_object_unref (child);
  g_object_unref (page);
}

static HdyTabPage *
insert_page (HdyTabView *self,
             GtkWidget  *child,
             HdyTabPage *parent,
             gint        position,
             gboolean    pinned)
{
  g_autoptr (HdyTabPage) page =
    g_object_new (HDY_TYPE_TAB_PAGE,
                  "child", child,
                  "parent", parent,
                  NULL);

  set_page_pinned (page, pinned);

  attach_page (self, page, position);

  if (!self->selected_page)
    hdy_tab_view_set_selected_page (self, page);

  return page;
}

static gboolean
close_page_cb (HdyTabView *self,
               HdyTabPage *page)
{
  hdy_tab_view_close_page_finish (self, page,
                                  !hdy_tab_page_get_pinned (page));

  return GDK_EVENT_STOP;
}

static gboolean
select_page (HdyTabView       *self,
             GtkDirectionType  direction,
             gboolean          last)
{
  gboolean is_rtl, success = last;

  if (!self->selected_page)
    return FALSE;

  is_rtl = gtk_widget_get_direction (GTK_WIDGET (self)) == GTK_TEXT_DIR_RTL;

  if (direction == GTK_DIR_LEFT)
    direction = is_rtl ? GTK_DIR_TAB_FORWARD : GTK_DIR_TAB_BACKWARD;
  else if (direction == GTK_DIR_RIGHT)
    direction = is_rtl ? GTK_DIR_TAB_BACKWARD : GTK_DIR_TAB_FORWARD;

  if (direction == GTK_DIR_TAB_BACKWARD) {
    if (last)
      success = hdy_tab_view_select_first_page (self);
    else
      success = hdy_tab_view_select_previous_page (self);
  } else if (direction == GTK_DIR_TAB_FORWARD) {
    if (last)
      success = hdy_tab_view_select_last_page (self);
    else
      success = hdy_tab_view_select_next_page (self);
  }

  gtk_widget_grab_focus (hdy_tab_page_get_child (self->selected_page));

  return success;
}

static gboolean
reorder_page (HdyTabView       *self,
              GtkDirectionType  direction,
              gboolean          last)
{
  gboolean is_rtl, success = last;

  if (!self->selected_page)
    return FALSE;

  is_rtl = gtk_widget_get_direction (GTK_WIDGET (self)) == GTK_TEXT_DIR_RTL;

  if (direction == GTK_DIR_LEFT)
    direction = is_rtl ? GTK_DIR_TAB_FORWARD : GTK_DIR_TAB_BACKWARD;
  else if (direction == GTK_DIR_RIGHT)
    direction = is_rtl ? GTK_DIR_TAB_BACKWARD : GTK_DIR_TAB_FORWARD;

  if (direction == GTK_DIR_TAB_BACKWARD) {
    if (last)
      success = hdy_tab_view_reorder_first (self, self->selected_page);
    else
      success = hdy_tab_view_reorder_backward (self, self->selected_page);
  } else if (direction == GTK_DIR_TAB_FORWARD) {
    if (last)
      success = hdy_tab_view_reorder_last (self, self->selected_page);
    else
      success = hdy_tab_view_reorder_forward (self, self->selected_page);
  }

  return success;
}

static inline gboolean
handle_select_reorder_shortcuts (HdyTabView       *self,
                                 guint             keyval,
                                 GdkModifierType   state,
                                 guint             keysym,
                                 GtkDirectionType  direction,
                                 gboolean          last)
{
  /* All keypad keysyms are aligned at the same order as non-keypad ones */
  guint keypad_keysym = keysym - GDK_KEY_Left + GDK_KEY_KP_Left;
  gboolean success = FALSE;

  if (keyval != keysym && keyval != keypad_keysym)
    return GDK_EVENT_PROPAGATE;

  if (state == GDK_CONTROL_MASK)
    success = select_page (self, direction, last);
  else if (state == (GDK_CONTROL_MASK | GDK_SHIFT_MASK))
    success = reorder_page (self, direction, last);
  else
    return GDK_EVENT_PROPAGATE;

  if (!success)
    gtk_widget_error_bell (GTK_WIDGET (self));

  return GDK_EVENT_STOP;
}

static gboolean
shortcut_key_press_cb (HdyTabView  *self,
                       GdkEventKey *event,
                       GtkWidget   *widget)
{
  GdkModifierType default_modifiers = gtk_accelerator_get_default_mod_mask ();
  guint keyval;
  GdkModifierType state;
  GdkModifierType consumed;
  GdkKeymap *keymap;
  gint i;

  gdk_event_get_state ((GdkEvent *) event, &state);

  keymap = gdk_keymap_get_for_display (gtk_widget_get_display (widget));

  gdk_keymap_translate_keyboard_state (keymap,
                                       event->hardware_keycode,
                                       state,
                                       event->group,
                                       &keyval, NULL, NULL, &consumed);

  state &= ~consumed & default_modifiers;

  if (handle_select_reorder_shortcuts (self, keyval, state, GDK_KEY_Page_Up,
                                       GTK_DIR_TAB_BACKWARD, FALSE))
    return GDK_EVENT_STOP;

  if (handle_select_reorder_shortcuts (self, keyval, state, GDK_KEY_Page_Down,
                                       GTK_DIR_TAB_FORWARD, FALSE))
    return GDK_EVENT_STOP;

  if (handle_select_reorder_shortcuts (self, keyval, state, GDK_KEY_Home,
                                       GTK_DIR_TAB_BACKWARD, TRUE))
    return GDK_EVENT_STOP;

  if (handle_select_reorder_shortcuts (self, keyval, state, GDK_KEY_End,
                                       GTK_DIR_TAB_FORWARD, TRUE))
    return GDK_EVENT_STOP;

  if (keyval == GDK_KEY_Tab ||
      keyval == GDK_KEY_KP_Tab ||
      keyval == GDK_KEY_ISO_Left_Tab) {
    if (keyval == GDK_KEY_ISO_Left_Tab &&
        state == GDK_CONTROL_MASK)
      state = GDK_CONTROL_MASK | GDK_SHIFT_MASK;

    if (state == GDK_CONTROL_MASK) {
      if (!hdy_tab_view_select_next_page (self)) {
        HdyTabPage *page = hdy_tab_view_get_nth_page (self, 0);

        hdy_tab_view_set_selected_page (self, page);
      }

      return GDK_EVENT_STOP;
    }

    if (state == (GDK_CONTROL_MASK | GDK_SHIFT_MASK)) {
      if (!hdy_tab_view_select_previous_page (self)) {
        HdyTabPage *page = hdy_tab_view_get_nth_page (self, self->n_pages - 1);

        hdy_tab_view_set_selected_page (self, page);
      }

      return GDK_EVENT_STOP;
    }
  }

  for (i = 0; i <= 9; i++) {
    if ((keyval == GDK_KEY_0 + i || keyval == GDK_KEY_KP_0 + i) &&
        state == GDK_MOD1_MASK) {
      gint n_page = (i + 9) % 10; /* Alt+0 means page 10, not 0 */
      HdyTabPage *page;

      if (n_page >= self->n_pages)
        return GDK_EVENT_PROPAGATE;

      page = hdy_tab_view_get_nth_page (self, n_page);
      hdy_tab_view_set_selected_page (self, page);

      return GDK_EVENT_STOP;
    }
  }

  return GDK_EVENT_PROPAGATE;
}

static void
shortcut_widget_notify_cb (HdyTabView *self)
{
  g_signal_handlers_disconnect_by_func (self->shortcut_widget,
                                        shortcut_key_press_cb, self);

  self->shortcut_widget = NULL;

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_SHORTCUT_WIDGET]);
}

static void
hdy_tab_view_dispose (GObject *object)
{
  HdyTabView *self = HDY_TAB_VIEW (object);

  hdy_tab_view_set_shortcut_widget (self, NULL);

  while (self->n_pages) {
    HdyTabPage *page = hdy_tab_view_get_nth_page (self, 0);

    detach_page (self, page);
  }

  g_clear_object (&self->pages);

  G_OBJECT_CLASS (hdy_tab_view_parent_class)->dispose (object);
}

static void
hdy_tab_view_finalize (GObject *object)
{
  HdyTabView *self = (HdyTabView *) object;

  g_clear_object (&self->default_icon);
  g_clear_object (&self->menu_model);

  tab_view_list = g_slist_remove (tab_view_list, self);

  G_OBJECT_CLASS (hdy_tab_view_parent_class)->finalize (object);
}

static void
hdy_tab_view_get_property (GObject    *object,
                           guint       prop_id,
                           GValue     *value,
                           GParamSpec *pspec)
{
  HdyTabView *self = HDY_TAB_VIEW (object);

  switch (prop_id) {
  case PROP_N_PAGES:
    g_value_set_int (value, hdy_tab_view_get_n_pages (self));
    break;

  case PROP_N_PINNED_PAGES:
    g_value_set_int (value, hdy_tab_view_get_n_pinned_pages (self));
    break;

  case PROP_IS_TRANSFERRING_PAGE:
    g_value_set_boolean (value, hdy_tab_view_get_is_transferring_page (self));
    break;

  case PROP_SELECTED_PAGE:
    g_value_set_object (value, hdy_tab_view_get_selected_page (self));
    break;

  case PROP_DEFAULT_ICON:
    g_value_set_object (value, hdy_tab_view_get_default_icon (self));
    break;

  case PROP_MENU_MODEL:
    g_value_set_object (value, hdy_tab_view_get_menu_model (self));
    break;

  case PROP_SHORTCUT_WIDGET:
    g_value_set_object (value, hdy_tab_view_get_shortcut_widget (self));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_tab_view_set_property (GObject      *object,
                           guint         prop_id,
                           const GValue *value,
                           GParamSpec   *pspec)
{
  HdyTabView *self = HDY_TAB_VIEW (object);

  switch (prop_id) {
  case PROP_SELECTED_PAGE:
    hdy_tab_view_set_selected_page (self, g_value_get_object (value));
    break;

  case PROP_DEFAULT_ICON:
    hdy_tab_view_set_default_icon (self, g_value_get_object (value));
    break;

  case PROP_MENU_MODEL:
    hdy_tab_view_set_menu_model (self, g_value_get_object (value));
    break;

  case PROP_SHORTCUT_WIDGET:
    hdy_tab_view_set_shortcut_widget (self, g_value_get_object (value));
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_tab_view_class_init (HdyTabViewClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);

  object_class->dispose = hdy_tab_view_dispose;
  object_class->finalize = hdy_tab_view_finalize;
  object_class->get_property = hdy_tab_view_get_property;
  object_class->set_property = hdy_tab_view_set_property;

  /**
   * HdyTabView:n-pages:
   *
   * The number of pages in the tab view.
   *
   * Since: 1.2
   */
  props[PROP_N_PAGES] =
    g_param_spec_int ("n-pages",
                      _("Number of pages"),
                      _("The number of pages in the tab view"),
                      0, G_MAXINT, 0,
                      G_PARAM_READABLE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabView:n-pinned-pages:
   *
   * The number of pinned pages in the tab view.
   *
   * See hdy_tab_view_set_page_pinned().
   *
   * Since: 1.2
   */
  props[PROP_N_PINNED_PAGES] =
    g_param_spec_int ("n-pinned-pages",
                      _("Number of pinned pages"),
                      _("The number of pinned pages in the tab view"),
                      0, G_MAXINT, 0,
                      G_PARAM_READABLE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabView:is-transferring-page:
   *
   * Whether a page is being transferred.
   *
   * This property will be set to %TRUE when a drag-n-drop tab transfer starts
   * on any #HdyTabView, and to %FALSE after it ends.
   *
   * During the transfer, children cannot receive pointer input and a tab can
   * be safely dropped on the tab view.
   *
   * Since: 1.2
   */
  props[PROP_IS_TRANSFERRING_PAGE] =
    g_param_spec_boolean ("is-transferring-page",
                          _("Is transferring page"),
                          _("Whether a page is being transferred"),
                          FALSE,
                          G_PARAM_READABLE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabView:selected-page:
   *
   * The currently selected page.
   *
   * Since: 1.2
   */
  props[PROP_SELECTED_PAGE] =
    g_param_spec_object ("selected-page",
                         _("Selected page"),
                         _("The currently selected page"),
                         HDY_TYPE_TAB_PAGE,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabView:default-icon:
   *
   * Default page icon.
   *
   * If a page doesn't provide its own icon via #HdyTabPage:icon, default icon
   * may be used instead for contexts where having an icon is necessary.
   *
   * #HdyTabBar will use default icon for pinned tabs in case the page is not
   * loading, doesn't have an icon and an indicator. Default icon is never used
   * for tabs that aren't pinned.
   *
   * Since: 1.2
   */
  props[PROP_DEFAULT_ICON] =
    g_param_spec_object ("default-icon",
                         _("Default icon"),
                         _("Default page icon"),
                         G_TYPE_ICON,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabView:menu-model:
   *
   * Tab context menu model.
   *
   * When a context menu is shown for a tab, it will be constructed from the
   * provided menu model. Use #HdyTabView::setup-menu signal to set up the menu
   * actions for the particular tab.
   *
   * Since: 1.2
   */
  props[PROP_MENU_MODEL] =
    g_param_spec_object ("menu-model",
                         _("Menu model"),
                         _("Tab context menu model"),
                         G_TYPE_MENU_MODEL,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdyTabView:shortcut-widget:
   *
   * Tab shortcut widget, has the following shortcuts:
   * * Ctrl+Page Up - switch to the previous page
   * * Ctrl+Page Down - switch to the next page
   * * Ctrl+Home - switch to the first page
   * * Ctrl+End - switch to the last page
   * * Ctrl+Shift+Page Up - move the current page backward
   * * Ctrl+Shift+Page Down - move the current page forward
   * * Ctrl+Shift+Home - move the current page at the start
   * * Ctrl+Shift+End - move the current page at the end
   * * Ctrl+Tab - switch to the next page, with looping
   * * Ctrl+Shift+Tab - switch to the previous page, with looping
   * * Alt+1-9 - switch to pages 1-9
   * * Alt+0 - switch to page 10
   *
   * These shortcuts are always available on @self, this property is useful if
   * they should be available globally.
   *
   * Since: 1.2
   */
  props[PROP_SHORTCUT_WIDGET] =
    g_param_spec_object ("shortcut-widget",
                         _("Shortcut widget"),
                         _("Tab shortcut widget"),
                         GTK_TYPE_WIDGET,
                         G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  g_object_class_install_properties (object_class, LAST_PROP, props);

  /**
   * HdyTabView::page-attached:
   * @self: a #HdyTabView
   * @page: a page of @self
   * @position: the position of the page, starting from 0
   *
   * This signal is emitted when a page has been created or transferred to
   * @self.
   *
   * A typical reason to connect to this signal would be to connect to page
   * signals for things such as updating window title.
   *
   * Since: 1.2
   */
  signals[SIGNAL_PAGE_ATTACHED] =
    g_signal_new ("page-attached",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  0,
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  2,
                  HDY_TYPE_TAB_PAGE, G_TYPE_INT);

  /**
   * HdyTabView::page-detached:
   * @self: a #HdyTabView
   * @page: a page of @self
   * @position: the position of the removed page, starting from 0
   *
   * This signal is emitted when a page has been removed or transferred to
   * another view.
   *
   * A typical reason to connect to this signal would be to disconnect signal
   * handlers connected in the #HdyTabView::page-attached handler.
   *
   * It is important not to try and destroy the page child in the handler of
   * this function as the child might merely be moved to another window; use
   * child dispose handler for that or do it in sync with your
   * hdy_tab_view_close_page_finish() calls.
   *
   * Since: 1.2
   */
  signals[SIGNAL_PAGE_DETACHED] =
    g_signal_new ("page-detached",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  0,
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  2,
                  HDY_TYPE_TAB_PAGE, G_TYPE_INT);

  /**
   * HdyTabView::page-reordered:
   * @self: a #HdyTabView
   * @page: a page of @self
   * @position: the position @page was moved to, starting at 0
   *
   * This signal is emitted after @page has been reordered to @position.
   *
   * Since: 1.2
   */
  signals[SIGNAL_PAGE_REORDERED] =
    g_signal_new ("page-reordered",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  0,
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  2,
                  HDY_TYPE_TAB_PAGE, G_TYPE_INT);

  /**
   * HdyTabView::close-page:
   * @self: a #HdyTabView
   * @page: a page of @self
   *
   * This signal is emitted after hdy_tab_view_close_page() has been called for
   * @page.
   *
   * The handler is expected to call hdy_tab_view_close_page_finish() to confirm
   * or reject the closing.
   *
   * The default handler will immediately confirm closing for non-pinned pages,
   * or reject it for pinned pages, equivalent to the following example:
   *
   * |[<!-- language="C" -->
   * static gboolean
   * close_page_cb (HdyTabView *view,
   *                HdyTabPage *page,
   *                gpointer    user_data)
   * {
   *   hdy_tab_view_close_page_finish (view, page, !hdy_tab_page_get_pinned (page));
   *
   *   return GDK_EVENT_STOP;
   * }
   * ]|
   *
   * The hdy_tab_view_close_page_finish() doesn't have to happen during the
   * handler, so can be used to do asynchronous checks before confirming the
   * closing.
   *
   * A typical reason to connect to this signal is to show a confirmation dialog
   * for closing a tab.
   *
   * Since: 1.2
   */
  signals[SIGNAL_CLOSE_PAGE] =
    g_signal_new ("close-page",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  0,
                  g_signal_accumulator_true_handled,
                  NULL, NULL,
                  G_TYPE_BOOLEAN,
                  1,
                  HDY_TYPE_TAB_PAGE);

  /**
   * HdyTabView::setup-menu:
   * @self: a #HdyTabView
   * @page: a page of @self, or %NULL
   *
   * This signal is emitted before a context menu is opened for @page, and after
   * it's closed, in the latter case the @page will be set to %NULL.
   *
   * It can be used to set up menu actions before showing the menu, for example
   * disable actions not applicable to @page.
   *
   * Since: 1.2
   */
  signals[SIGNAL_SETUP_MENU] =
    g_signal_new ("setup-menu",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  0,
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  1,
                  HDY_TYPE_TAB_PAGE);

  /**
   * HdyTabView::create-window:
   * @self: a #HdyTabView
   *
   * This signal is emitted when a tab is dropped onto desktop and should be
   * transferred into a new window.
   *
   * The signal handler is expected to create a new window, position it as
   * needed and return its #HdyTabView that the page will be transferred into.
   *
   * Returns: (transfer none) (nullable): the #HdyTabView from the new window
   *
   * Since: 1.2
   */
  signals[SIGNAL_CREATE_WINDOW] =
    g_signal_new ("create-window",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  0,
                  object_handled_accumulator,
                  NULL, NULL,
                  HDY_TYPE_TAB_VIEW,
                  0);

  /**
   * HdyTabView::indicator-activated:
   * @self: a #HdyTabView
   * @page: a page of @self
   *
   * This signal is emitted after the indicator icon on @page has been activated.
   *
   * See #HdyTabPage:indicator-icon and #HdyTabPage:indicator-activatable.
   *
   * Since: 1.2
   */
  signals[SIGNAL_INDICATOR_ACTIVATED] =
    g_signal_new ("indicator-activated",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  0,
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  1,
                  HDY_TYPE_TAB_PAGE);

  g_signal_override_class_handler ("close-page",
                                   G_TYPE_FROM_CLASS (klass),
                                   G_CALLBACK (close_page_cb));

  gtk_widget_class_set_css_name (widget_class, "tabview");
}

static void
hdy_tab_view_init (HdyTabView *self)
{
  GtkWidget *overlay, *drag_shield;

  self->pages = g_list_store_new (HDY_TYPE_TAB_PAGE);
  self->default_icon = G_ICON (g_themed_icon_new ("hdy-tab-icon-missing-symbolic"));

  overlay = gtk_overlay_new ();
  gtk_widget_show (overlay);
  gtk_container_add (GTK_CONTAINER (self), overlay);

  self->stack = GTK_STACK (gtk_stack_new ());
  gtk_widget_show (GTK_WIDGET (self->stack));
  gtk_container_add (GTK_CONTAINER (overlay), GTK_WIDGET (self->stack));

  drag_shield = gtk_event_box_new ();
  gtk_widget_set_no_show_all (drag_shield, TRUE);
  gtk_widget_add_events (drag_shield, GDK_ALL_EVENTS_MASK);
  gtk_overlay_add_overlay (GTK_OVERLAY (overlay), drag_shield);

  g_object_bind_property (self, "is-transferring-page",
                          drag_shield, "visible",
                          G_BINDING_DEFAULT);

  gtk_drag_dest_set (GTK_WIDGET (self),
                     GTK_DEST_DEFAULT_MOTION,
                     dst_targets,
                     G_N_ELEMENTS (dst_targets),
                     GDK_ACTION_MOVE);

  tab_view_list = g_slist_prepend (tab_view_list, self);

  g_signal_connect_object (self, "key-press-event",
                           G_CALLBACK (shortcut_key_press_cb), self,
                           G_CONNECT_SWAPPED);
}

/**
 * hdy_tab_page_get_child:
 * @self: a #HdyTabPage
 *
 * Gets the child of @self.
 *
 * Returns: (transfer none): the child of @self
 *
 * Since: 1.2
 */
GtkWidget *
hdy_tab_page_get_child (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), NULL);

  return self->child;
}

/**
 * hdy_tab_page_get_parent:
 * @self: a #HdyTabPage
 *
 * Gets the parent page of @self, or %NULL if the @self does not have a parent.
 *
 * See hdy_tab_view_add_page() and hdy_tab_view_close_page().
 *
 * Returns: (transfer none) (nullable): the parent page of @self, or %NULL
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_page_get_parent (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), NULL);

  return self->parent;
}

/**
 * hdy_tab_page_get_selected:
 * @self: a #HdyTabPage
 *
 * Gets whether @self is selected. See hdy_tab_view_set_selected_page().
 *
 * Returns: whether @self is selected
 *
 * Since: 1.2
 */
gboolean
hdy_tab_page_get_selected (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), FALSE);

  return self->selected;
}

/**
 * hdy_tab_page_get_pinned:
 * @self: a #HdyTabPage
 *
 * Gets whether @self is pinned. See hdy_tab_view_set_page_pinned().
 *
 * Returns: whether @self is pinned
 *
 * Since: 1.2
 */
gboolean
hdy_tab_page_get_pinned (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), FALSE);

  return self->pinned;
}

/**
 * hdy_tab_page_get_title:
 * @self: a #HdyTabPage
 *
 * Gets the title of @self, see hdy_tab_page_set_title().
 *
 * Returns: (nullable): the title of @self
 *
 * Since: 1.2
 */
const gchar *
hdy_tab_page_get_title (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), NULL);

  return self->title;
}

/**
 * hdy_tab_page_set_title:
 * @self: a #HdyTabPage
 * @title: (nullable): the title of @self
 *
 * Sets the title of @self.
 *
 * #HdyTabBar will display it in the center of the tab representing @self
 * unless it's pinned, and will use it as a tooltip unless #HdyTabPage:tooltip
 * is set.
 *
 * Since: 1.2
 */
void
hdy_tab_page_set_title (HdyTabPage  *self,
                        const gchar *title)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));

  if (!g_strcmp0 (title, self->title))
    return;

  g_clear_pointer (&self->title, g_free);
  self->title = g_strdup (title);

  g_object_notify_by_pspec (G_OBJECT (self), page_props[PAGE_PROP_TITLE]);
}

/**
 * hdy_tab_page_get_tooltip:
 * @self: a #HdyTabPage
 *
 * Gets the tooltip of @self, see hdy_tab_page_set_tooltip().
 *
 * Returns: (nullable): the tooltip of @self
 *
 * Since: 1.2
 */
const gchar *
hdy_tab_page_get_tooltip (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), NULL);

  return self->tooltip;
}

/**
 * hdy_tab_page_set_tooltip:
 * @self: a #HdyTabPage
 * @tooltip: (nullable): the tooltip of @self
 *
 * Sets the tooltip of @self, marked up with the Pango text markup language.
 *
 * If not set, #HdyTabBar will use #HdyTabPage:title as a tooltip instead.
 *
 * Since: 1.2
 */
void
hdy_tab_page_set_tooltip (HdyTabPage  *self,
                          const gchar *tooltip)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));

  if (!g_strcmp0 (tooltip, self->tooltip))
    return;

  g_clear_pointer (&self->tooltip, g_free);
  self->tooltip = g_strdup (tooltip);

  g_object_notify_by_pspec (G_OBJECT (self), page_props[PAGE_PROP_TOOLTIP]);
}

/**
 * hdy_tab_page_get_icon:
 * @self: a #HdyTabPage
 *
 * Gets the icon of @self, see hdy_tab_page_set_icon().
 *
 * Returns: (transfer none) (nullable): the icon of @self
 *
 * Since: 1.2
 */
GIcon *
hdy_tab_page_get_icon (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), NULL);

  return self->icon;
}

/**
 * hdy_tab_page_set_icon:
 * @self: a #HdyTabPage
 * @icon: (nullable): the icon of @self
 *
 * Sets the icon of @self, displayed next to the title.
 *
 * #HdyTabBar will not show the icon if #HdyTabPage:loading is set to %TRUE,
 * or if @self is pinned and #HdyTabPage:indicator-icon is set.
 *
 * Since: 1.2
 */
void
hdy_tab_page_set_icon (HdyTabPage *self,
                       GIcon      *icon)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));
  g_return_if_fail (G_IS_ICON (icon) || icon == NULL);

  if (self->icon == icon)
    return;

  g_set_object (&self->icon, icon);

  g_object_notify_by_pspec (G_OBJECT (self), page_props[PAGE_PROP_ICON]);
}

/**
 * hdy_tab_page_get_loading:
 * @self: a #HdyTabPage
 *
 * Gets whether @self is loading, see hdy_tab_page_set_loading().
 *
 * Returns: whether @self is loading
 *
 * Since: 1.2
 */
gboolean
hdy_tab_page_get_loading (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), FALSE);

  return self->loading;
}

/**
 * hdy_tab_page_set_loading:
 * @self: a #HdyTabPage
 * @loading: whether @self is loading
 *
 * Sets wether @self is loading.
 *
 * If set to %TRUE, #HdyTabBar will display a spinner in place of icon.
 *
 * If @self is pinned and #HdyTabPage:indicator-icon is set, the loading status
 * will not be visible.
 *
 * Since: 1.2
 */
void
hdy_tab_page_set_loading (HdyTabPage *self,
                          gboolean    loading)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));

  loading = !!loading;

  if (self->loading == loading)
    return;

  self->loading = loading;

  g_object_notify_by_pspec (G_OBJECT (self), page_props[PAGE_PROP_LOADING]);
}

/**
 * hdy_tab_page_get_indicator_icon:
 * @self: a #HdyTabPage
 *
 * Gets the indicator icon of @self, see hdy_tab_page_set_indicator_icon().
 *
 * Returns: (transfer none) (nullable): the indicator icon of @self
 *
 * Since: 1.2
 */
GIcon *
hdy_tab_page_get_indicator_icon (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), NULL);

  return self->indicator_icon;
}

/**
 * hdy_tab_page_set_indicator_icon:
 * @self: a #HdyTabPage
 * @indicator_icon: (nullable): the indicator icon of @self
 *
 * Sets the indicator icon of @self.
 *
 * A common use case is an audio or camera indicator in a web browser.
 *
 * #HdyTabPage will show it at the beginning of the tab, alongside icon
 * representing #HdyTabPage:icon or loading spinner.
 *
 * If the page is pinned, the indicator will be shown instead of icon or spinner.
 *
 * If #HdyTabPage:indicator-activatable is set to %TRUE, indicator icon
 * can act as a button.
 *
 * Since: 1.2
 */
void
hdy_tab_page_set_indicator_icon (HdyTabPage *self,
                                 GIcon      *indicator_icon)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));
  g_return_if_fail (G_IS_ICON (indicator_icon) || indicator_icon == NULL);

  if (self->indicator_icon == indicator_icon)
    return;

  g_set_object (&self->indicator_icon, indicator_icon);

  g_object_notify_by_pspec (G_OBJECT (self), page_props[PAGE_PROP_INDICATOR_ICON]);
}

/**
 * hdy_tab_page_get_indicator_activatable:
 * @self: a #HdyTabPage
 *
 *
 * Gets whether the indicator of @self is activatable, see
 * hdy_tab_page_set_indicator_activatable().
 *
 * Returns: whether the indicator is activatable
 *
 * Since: 1.2
 */
gboolean
hdy_tab_page_get_indicator_activatable (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), FALSE);

  return self->indicator_activatable;
}

/**
 * hdy_tab_page_set_indicator_activatable:
 * @self: a #HdyTabPage
 * @activatable: whether the indicator is activatable
 *
 * sets whether the indicator of @self is activatable.
 *
 * If set to %TRUE, #HdyTabView::indicator-activated will be emitted when
 * the indicator is clicked.
 *
 * If #HdyTabPage:indicator-icon is not set, does nothing.
 *
 * Since: 1.2
 */
void
hdy_tab_page_set_indicator_activatable (HdyTabPage *self,
                                        gboolean    activatable)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));

  activatable = !!activatable;

  if (self->indicator_activatable == activatable)
    return;

  self->indicator_activatable = activatable;

  g_object_notify_by_pspec (G_OBJECT (self), page_props[PAGE_PROP_INDICATOR_ACTIVATABLE]);
}

/**
 * hdy_tab_page_get_needs_attention:
 * @self: a #HdyTabPage
 *
 * Gets whether @self needs attention, see hdy_tab_page_set_needs_attention().
 *
 * Returns: whether @self needs attention
 *
 * Since: 1.2
 */
gboolean
hdy_tab_page_get_needs_attention (HdyTabPage *self)
{
  g_return_val_if_fail (HDY_IS_TAB_PAGE (self), FALSE);

  return self->needs_attention;
}

/**
 * hdy_tab_page_set_needs_attention:
 * @self: a #HdyTabPage
 * @needs_attention: whether @self needs attention
 *
 * Sets whether @self needs attention.
 *
 * #HdyTabBar will display a glow under the tab representing @self if set to
 * %TRUE. If the tab is not visible, the corresponding edge of the tab bar will
 * be highlighted.
 *
 * Since: 1.2
 */
void
hdy_tab_page_set_needs_attention (HdyTabPage *self,
                                  gboolean    needs_attention)
{
  g_return_if_fail (HDY_IS_TAB_PAGE (self));

  needs_attention = !!needs_attention;

  if (self->needs_attention == needs_attention)
    return;

  self->needs_attention = needs_attention;

  g_object_notify_by_pspec (G_OBJECT (self), page_props[PAGE_PROP_NEEDS_ATTENTION]);
}

/**
 * hdy_tab_view_new:
 *
 * Creates a new #HdyTabView widget.
 *
 * Returns: a new #HdyTabView
 *
 * Since: 1.2
 */
HdyTabView *
hdy_tab_view_new (void)
{
  return g_object_new (HDY_TYPE_TAB_VIEW, NULL);
}

/**
 * hdy_tab_view_get_n_pages:
 * @self: a #HdyTabView
 *
 * Gets the number of pages in @self.
 *
 * Returns: the number of pages in @self
 *
 * Since: 1.2
 */
gint
hdy_tab_view_get_n_pages (HdyTabView *self)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), 0);

  return self->n_pages;
}

/**
 * hdy_tab_view_get_n_pinned_pages:
 * @self: a #HdyTabView
 *
 * Gets the number of pinned pages in @self.
 *
 * See hdy_tab_view_set_page_pinned().
 *
 * Returns: the number of pinned pages in @self
 *
 * Since: 1.2
 */
gint
hdy_tab_view_get_n_pinned_pages (HdyTabView *self)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), 0);

  return self->n_pinned_pages;
}

/**
 * hdy_tab_view_get_is_transferring_page:
 * @self: a #HdyTabView
 *
 * Whether a page is being transferred.
 *
 * Gets the value of #HdyTabView:is-transferring-page property.
 *
 * Returns: whether a page is being transferred
 *
 * Since: 1.2
 */
gboolean
hdy_tab_view_get_is_transferring_page (HdyTabView *self)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);

  return self->transfer_count > 0;
}

/**
 * hdy_tab_view_get_selected_page:
 * @self: a #HdyTabView
 *
 * Gets the currently selected page in @self.
 *
 * Returns: (transfer none) (nullable): the selected page in @self
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_get_selected_page (HdyTabView *self)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);

  return self->selected_page;
}

/**
 * hdy_tab_view_set_selected_page:
 * @self: a #HdyTabView
 * @selected_page: a page in @self
 *
 * Sets the currently selected page in @self.
 *
 * Since: 1.2
 */
void
hdy_tab_view_set_selected_page (HdyTabView *self,
                                HdyTabPage *selected_page)
{
  g_return_if_fail (HDY_IS_TAB_VIEW (self));

  if (self->n_pages > 0) {
    g_return_if_fail (HDY_IS_TAB_PAGE (selected_page));
    g_return_if_fail (page_belongs_to_this_view (self, selected_page));
  } else {
    g_return_if_fail (selected_page == NULL);
  }

  if (self->selected_page == selected_page)
    return;

  if (self->selected_page)
    set_page_selected (self->selected_page, FALSE);

  self->selected_page = selected_page;

  if (self->selected_page) {
    gtk_stack_set_visible_child (self->stack,
                                 hdy_tab_page_get_child (selected_page));
    set_page_selected (self->selected_page, TRUE);
  }

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_SELECTED_PAGE]);
}

/**
 * hdy_tab_view_select_previous_page:
 * @self: a #HdyTabView
 *
 * Selects the page before the currently selected page.
 *
 * If the first page was already selected, this function does nothing.
 *
 * Returns: %TRUE if the selected page was changed, %FALSE otherwise
 *
 * Since: 1.2
 */
gboolean
hdy_tab_view_select_previous_page (HdyTabView *self)
{
  HdyTabPage *page;
  gint pos;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);

  if (!self->selected_page)
    return FALSE;

  pos = hdy_tab_view_get_page_position (self, self->selected_page);

  if (pos <= 0)
    return FALSE;

  page = hdy_tab_view_get_nth_page (self, pos - 1);

  hdy_tab_view_set_selected_page (self, page);

  return TRUE;
}

/**
 * hdy_tab_view_select_next_page:
 * @self: a #HdyTabView
 *
 * Selects the page after the currently selected page.
 *
 * If the last page was already selected, this function does nothing.
 *
 * Returns: %TRUE if the selected page was changed, %FALSE otherwise
 *
 * Since: 1.2
 */
gboolean
hdy_tab_view_select_next_page (HdyTabView *self)
{
  HdyTabPage *page;
  gint pos;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);

  if (!self->selected_page)
    return FALSE;

  pos = hdy_tab_view_get_page_position (self, self->selected_page);

  if (pos >= self->n_pages - 1)
    return FALSE;

  page = hdy_tab_view_get_nth_page (self, pos + 1);

  hdy_tab_view_set_selected_page (self, page);

  return TRUE;
}

gboolean
hdy_tab_view_select_first_page (HdyTabView *self)
{
  HdyTabPage *page;
  gint pos;
  gboolean pinned;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);

  if (!self->selected_page)
    return FALSE;

  pinned = hdy_tab_page_get_pinned (self->selected_page);
  pos = pinned ? 0 : self->n_pinned_pages;

  page = hdy_tab_view_get_nth_page (self, pos);

  /* If we're on the first non-pinned tab, go to the first pinned tab */
  if (page == self->selected_page && !pinned)
    page = hdy_tab_view_get_nth_page (self, 0);

  if (page == self->selected_page)
    return FALSE;

  hdy_tab_view_set_selected_page (self, page);

  return TRUE;
}

gboolean
hdy_tab_view_select_last_page (HdyTabView *self)
{
  HdyTabPage *page;
  gint pos;
  gboolean pinned;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);

  if (!self->selected_page)
    return FALSE;

  pinned = hdy_tab_page_get_pinned (self->selected_page);
  pos = (pinned ? self->n_pinned_pages : self->n_pages) - 1;

  page = hdy_tab_view_get_nth_page (self, pos);

  /* If we're on the last pinned tab, go to the last non-pinned tab */
  if (page == self->selected_page && pinned)
    page = hdy_tab_view_get_nth_page (self, self->n_pages - 1);

  if (page == self->selected_page)
    return FALSE;

  hdy_tab_view_set_selected_page (self, page);

  return TRUE;
}

/**
 * hdy_tab_view_get_default_icon:
 * @self: a #HdyTabView
 *
 * Gets default icon of @self, see hdy_tab_view_set_default_icon().
 *
 * Returns: (transfer none): the default icon of @self.
 *
 * Since: 1.2
 */
GIcon *
hdy_tab_view_get_default_icon (HdyTabView *self)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);

  return self->default_icon;
}

/**
 * hdy_tab_view_set_default_icon:
 * @self: a #HdyTabView
 * @default_icon: the default icon
 *
 * Sets default page icon for @self.
 *
 * If a page doesn't provide its own icon via #HdyTabPage:icon, default icon
 * may be used instead for contexts where having an icon is necessary.
 *
 * #HdyTabBar will use default icon for pinned tabs in case the page is not
 * loading, doesn't have an icon and an indicator. Default icon is never used
 * for tabs that aren't pinned.
 *
 * By default, 'hdy-tab-icon-missing-symbolic' icon is used.
 *
 * Since: 1.2
 */
void
hdy_tab_view_set_default_icon (HdyTabView *self,
                               GIcon      *default_icon)
{
  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (G_IS_ICON (default_icon));

  if (self->default_icon == default_icon)
    return;

  g_set_object (&self->default_icon, default_icon);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_DEFAULT_ICON]);
}

/**
 * hdy_tab_view_get_menu_model:
 * @self: a #HdyTabView
 *
 * Gets the tab context menu model for @self, see hdy_tab_view_set_menu_model().
 *
 * Returns: (transfer none) (nullable): the tab context menu model for @self
 *
 * Since: 1.2
 */
GMenuModel *
hdy_tab_view_get_menu_model (HdyTabView *self)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);

  return self->menu_model;
}

/**
 * hdy_tab_view_set_menu_model:
 * @self: a #HdyTabView
 * @menu_model: (nullable): a menu model
 *
 * Sets the tab context menu model for @self.
 *
 * When a context menu is shown for a tab, it will be constructed from the
 * provided menu model. Use #HdyTabView::setup-menu signal to set up the menu
 * actions for the particular tab.
 *
 * Since: 1.2
 */
void
hdy_tab_view_set_menu_model (HdyTabView *self,
                             GMenuModel *menu_model)
{
  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (G_IS_MENU_MODEL (menu_model));

  if (self->menu_model == menu_model)
    return;

  g_set_object (&self->menu_model, menu_model);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_MENU_MODEL]);
}

/**
 * hdy_tab_view_get_shortcut_widget:
 * @self: a #HdyTabView
 *
 * Gets the shortcut widget for @self, see hdy_tab_view_set_shortcut_widget().
 *
 * Returns: (transfer none) (nullable): the shortcut widget for @self
 *
 * Since: 1.2
 */
GtkWidget *
hdy_tab_view_get_shortcut_widget (HdyTabView *self)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);

  return self->shortcut_widget;
}

/**
 * hdy_tab_view_set_shortcut_widget:
 * @self: a #HdyTabView
 * @widget: (nullable): a shortcut widget
 *
 * Sets the shortcut widget for @self.
 *
 * Registers the following shortcuts on @widget:
 * * Ctrl+Page Up - switch to the previous page
 * * Ctrl+Page Down - switch to the next page
 * * Ctrl+Home - switch to the first page
 * * Ctrl+End - switch to the last page
 * * Ctrl+Shift+Page Up - move the current page backward
 * * Ctrl+Shift+Page Down - move the current page forward
 * * Ctrl+Shift+Home - move the current page at the start
 * * Ctrl+Shift+End - move the current page at the end
 * * Ctrl+Tab - switch to the next page, with looping
 * * Ctrl+Shift+Tab - switch to the previous page, with looping
 * * Alt+1-9 - switch to pages 1-9
 * * Alt+0 - switch to page 10
 *
 * These shortcuts are always available on @self, this function is useful if
 * they should be available globally.
 *
 * Since: 1.2
 */
void
hdy_tab_view_set_shortcut_widget (HdyTabView *self,
                                  GtkWidget  *widget)
{
  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (GTK_IS_WIDGET (widget) || widget == NULL);

  if (widget == self->shortcut_widget)
    return;

  if (self->shortcut_widget) {
    g_signal_handlers_disconnect_by_func (self->shortcut_widget,
                                          shortcut_key_press_cb, self);

    g_object_weak_unref (G_OBJECT (self->shortcut_widget),
                         (GWeakNotify) shortcut_widget_notify_cb,
                         self);
  }

  self->shortcut_widget = widget;

  if (self->shortcut_widget) {
    g_object_weak_ref (G_OBJECT (self->shortcut_widget),
                       (GWeakNotify) shortcut_widget_notify_cb,
                       self);

    g_signal_connect_swapped (self->shortcut_widget, "key-press-event",
                              G_CALLBACK (shortcut_key_press_cb), self);
  }

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_SHORTCUT_WIDGET]);
}

/**
 * hdy_tab_view_set_page_pinned:
 * @self: a #HdyTabView
 * @page: a page of @self
 * @pinned: whether @page should be pinned
 *
 * Pins or unpins @page.
 *
 * Pinned pages are guaranteed to be placed before all non-pinned pages; at any
 * given moment the first #HdyTabView:n-pinned-pages pages in @self are
 * guaranteed to be pinned.
 *
 * When a page is pinned or unpinned, it's automatically reordered: pinning a
 * page moves it after other pinned pages; unpinning a page moves it before
 * other non-pinned pages.
 *
 * Pinned pages can still be reordered between each other.
 *
 * #HdyTabBar will display pinned pages in a compact form, never showing the
 * title or close button, and only showing a single icon, selected in the
 * following order:
 *
 * 1. #HdyTabPage:indicator-icon
 * 2. A spinner if #HdyTabPage:loading is %TRUE
 * 3. #HdyTabPage:icon
 * 4. #HdyTabView:default-icon
 *
 * Pinned pages cannot be closed by default, see #HdyTabView::close-page for how
 * to override that behavior.
 *
 * Since: 1.2
 */
void
hdy_tab_view_set_page_pinned (HdyTabView *self,
                              HdyTabPage *page,
                              gboolean    pinned)
{
  gint pos;

  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page));
  g_return_if_fail (page_belongs_to_this_view (self, page));

  pinned = !!pinned;

  if (hdy_tab_page_get_pinned (page) == pinned)
    return;

  pos = hdy_tab_view_get_page_position (self, page);

  g_object_ref (page);

  g_list_store_remove (self->pages, pos);

  pos = self->n_pinned_pages;

  if (!pinned)
    pos--;

  g_list_store_insert (self->pages, pos, page);

  g_object_unref (page);

  if (pinned)
    pos++;

  gtk_container_child_set (GTK_CONTAINER (self->stack),
                           hdy_tab_page_get_child (page),
                           "position", self->n_pinned_pages,
                           NULL);

  set_n_pinned_pages (self, pos);

  set_page_pinned (page, pinned);
}

/**
 * hdy_tab_view_get_page:
 * @self: a #HdyTabView
 * @child: a child in @self
 *
 * Gets the #HdyTabPage object representing @child.
 *
 * Returns: (transfer none): the #HdyTabPage representing @child
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_get_page (HdyTabView *self,
                       GtkWidget  *child)
{
  gint i;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);
  g_return_val_if_fail (GTK_IS_WIDGET (child), NULL);
  g_return_val_if_fail (gtk_widget_get_parent (child) == GTK_WIDGET (self->stack), NULL);

  for (i = 0; i < self->n_pages; i++) {
    HdyTabPage *page = hdy_tab_view_get_nth_page (self, i);

    if (hdy_tab_page_get_child (page) == child)
      return page;
  }

  g_assert_not_reached ();
}

/**
 * hdy_tab_view_get_nth_page:
 * @self: a #HdyTabView
 * @position: the index of the page in @self, starting from 0
 *
 * Gets the #HdyTabPage representing the child at @position.
 *
 * Returns: (transfer none): the page object at @position
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_get_nth_page (HdyTabView *self,
                           gint        position)
{
  g_autoptr (HdyTabPage) page = NULL;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);
  g_return_val_if_fail (position >= 0, NULL);
  g_return_val_if_fail (position < self->n_pages, NULL);

  page = g_list_model_get_item (G_LIST_MODEL (self->pages), (guint) position);

  return page;
}

/**
 * hdy_tab_view_get_page_position:
 * @self: a #HdyTabView
 * @page: a page of @self
 *
 * Finds the position of @page in @self, starting from 0.
 *
 * Returns: the position of @page in @self
 *
 * Since: 1.2
 */
gint
hdy_tab_view_get_page_position (HdyTabView *self,
                                HdyTabPage *page)
{
  gint i;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), -1);
  g_return_val_if_fail (HDY_IS_TAB_PAGE (page), -1);
  g_return_val_if_fail (page_belongs_to_this_view (self, page), -1);

  for (i = 0; i < self->n_pages; i++) {
    HdyTabPage *p = hdy_tab_view_get_nth_page (self, i);

    if (page == p)
      return i;
  }

  g_assert_not_reached ();
}

/**
 * hdy_tab_view_add_page:
 * @self: a #HdyTabView
 * @child: a widget to add
 * @parent: (nullable): a parent page for @child, or %NULL
 *
 * Adds @child to @self with @parent as the parent.
 *
 * This function can be used to automatically position new pages, and to select
 * the correct page when this page is closed while being selected (see
 * hdy_tab_view_close_page()).
 *
 * If @parent is %NULL, this function is equivalent to hdy_tab_view_append().
 *
 * Returns: (transfer none): the page object representing @child
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_add_page (HdyTabView *self,
                       GtkWidget  *child,
                       HdyTabPage *parent)
{
  gint position;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);
  g_return_val_if_fail (GTK_IS_WIDGET (child), NULL);
  g_return_val_if_fail (HDY_IS_TAB_PAGE (parent) || parent == NULL, NULL);

  if (parent) {
    HdyTabPage *page;

    g_return_val_if_fail (page_belongs_to_this_view (self, parent), NULL);

    if (hdy_tab_page_get_pinned (parent))
      position = self->n_pinned_pages - 1;
    else
      position = hdy_tab_view_get_page_position (self, parent);

    do {
      position++;

      if (position >= self->n_pages)
        break;

      page = hdy_tab_view_get_nth_page (self, position);
    } while (is_descendant_of (page, parent));
  } else {
    position = self->n_pages;
  }

  return insert_page (self, child, parent, position, FALSE);
}

/**
 * hdy_tab_view_insert:
 * @self: a #HdyTabView
 * @child: a widget to add
 * @position: the position to add @child at, starting from 0
 *
 * Inserts a non-pinned page at @position.
 *
 * It's an error to try to insert a page before a pinned page, in that case
 * hdy_tab_view_insert_pinned() should be used instead.
 *
 * Returns: (transfer none): the page object representing @child
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_insert (HdyTabView *self,
                     GtkWidget  *child,
                     gint        position)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);
  g_return_val_if_fail (GTK_IS_WIDGET (child), NULL);
  g_return_val_if_fail (position >= self->n_pinned_pages, NULL);
  g_return_val_if_fail (position <= self->n_pages, NULL);

  return insert_page (self, child, NULL, position, FALSE);
}

/**
 * hdy_tab_view_prepend:
 * @self: a #HdyTabView
 * @child: a widget to add
 *
 * Inserts @child as the first non-pinned page.
 *
 * Returns: (transfer none): the page object representing @child
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_prepend (HdyTabView *self,
                      GtkWidget  *child)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);
  g_return_val_if_fail (GTK_IS_WIDGET (child), NULL);

  return insert_page (self, child, NULL, self->n_pinned_pages, FALSE);
}

/**
 * hdy_tab_view_append:
 * @self: a #HdyTabView
 * @child: a widget to add
 *
 * Inserts @child as the last non-pinned page.
 *
 * Returns: (transfer none): the page object representing @child
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_append (HdyTabView *self,
                     GtkWidget  *child)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);
  g_return_val_if_fail (GTK_IS_WIDGET (child), NULL);

  return insert_page (self, child, NULL, self->n_pages, FALSE);
}

/**
 * hdy_tab_view_insert_pinned:
 * @self: a #HdyTabView
 * @child: a widget to add
 * @position: the position to add @child at, starting from 0
 *
 * Inserts a pinned page at @position.
 *
 * It's an error to try to insert a pinned page after a non-pinned page, in
 * that case hdy_tab_view_insert() should be used instead.
 *
 * Returns: (transfer none): the page object representing @child
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_insert_pinned (HdyTabView *self,
                            GtkWidget  *child,
                            gint        position)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);
  g_return_val_if_fail (GTK_IS_WIDGET (child), NULL);
  g_return_val_if_fail (position >= 0, NULL);
  g_return_val_if_fail (position <= self->n_pinned_pages, NULL);

  return insert_page (self, child, NULL, position, TRUE);
}

/**
 * hdy_tab_view_prepend_pinned:
 * @self: a #HdyTabView
 * @child: a widget to add
 *
 * Inserts @child as the first pinned page.
 *
 * Returns: (transfer none): the page object representing @child
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_prepend_pinned (HdyTabView *self,
                             GtkWidget  *child)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);
  g_return_val_if_fail (GTK_IS_WIDGET (child), NULL);

  return insert_page (self, child, NULL, 0, TRUE);
}

/**
 * hdy_tab_view_append_pinned:
 * @self: a #HdyTabView
 * @child: a widget to add
 *
 * Inserts @child as the last pinned page.
 *
 * Returns: (transfer none): the page object representing @child
 *
 * Since: 1.2
 */
HdyTabPage *
hdy_tab_view_append_pinned (HdyTabView *self,
                            GtkWidget  *child)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);
  g_return_val_if_fail (GTK_IS_WIDGET (child), NULL);

  return insert_page (self, child, NULL, self->n_pinned_pages, TRUE);
}

/**
 * hdy_tab_view_close_page:
 * @self: a #HdyTabView
 * @page: a page of @self
 *
 * Requests to close @page.
 *
 * Calling this function will result in #HdyTabView::close-page signal being
 * emitted for @page. Closing the page can then be confirmed or denied via
 * hdy_tab_view_close_page_finish().
 *
 * If the page is waiting for a hdy_tab_view_close_page_finish() call, this
 * function will do nothing.
 *
 * The default handler for #HdyTabView::close-page will immediately confirm
 * closing the page if it's non-pinned, or reject it if it's pinned. This
 * behavior can be changed by registering your own handler for that signal.
 *
 * If @page was selected, another page will be selected instead:
 *
 * If the #HdyTabPage:parent value is %NULL, the next page will be selected when
 * possible, or if the page was already last, the previous page will be selected
 * instead.
 *
 * If it's not %NULL, the previous page will be selected if it's a
 * descendant (possibly indirect) of the parent. If both the previous page and
 * the parent are pinned, the parent will be selected instead.
 *
 * Since: 1.2
 */
void
hdy_tab_view_close_page (HdyTabView *self,
                         HdyTabPage *page)
{
  gboolean ret;

  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page));
  g_return_if_fail (page_belongs_to_this_view (self, page));

  if (page->closing)
    return;

  page->closing = TRUE;
  g_signal_emit (self, signals[SIGNAL_CLOSE_PAGE], 0, page, &ret);
}

/**
 * hdy_tab_view_close_page_finish:
 * @self: a #HdyTabView
 * @page: a page of @self
 * @confirm: whether to confirm or deny closing @page
 *
 * Completes a hdy_tab_view_close_page() call for @page.
 *
 * If @confirm is %TRUE, @page will be closed. If it's %FALSE, ite will be
 * reverted to its previous state and hdy_tab_view_close_page() can be called
 * for it again.
 *
 * This function should not be called unless a custom handler for
 * #HdyTabView::close-page is used.
 *
 * Since: 1.2
 */
void
hdy_tab_view_close_page_finish (HdyTabView *self,
                                HdyTabPage *page,
                                gboolean    confirm)
{
  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page));
  g_return_if_fail (page_belongs_to_this_view (self, page));
  g_return_if_fail (page->closing);

  page->closing = FALSE;

  if (confirm)
    detach_page (self, page);
}

/**
 * hdy_tab_view_close_other_pages:
 * @self: a #HdyTabView
 * @page: a page of @self
 *
 * Requests to close all pages other than @page.
 *
 * Since: 1.2
 */
void
hdy_tab_view_close_other_pages (HdyTabView *self,
                                HdyTabPage *page)
{
  gint i;

  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page));
  g_return_if_fail (page_belongs_to_this_view (self, page));

  for (i = self->n_pages - 1; i >= 0; i--) {
    HdyTabPage *p = hdy_tab_view_get_nth_page (self, i);

    if (p == page)
      continue;

    hdy_tab_view_close_page (self, p);
  }
}

/**
 * hdy_tab_view_close_pages_before:
 * @self: a #HdyTabView
 * @page: a page of @self
 *
 * Requests to close all pages before @page.
 *
 * Since: 1.2
 */
void
hdy_tab_view_close_pages_before (HdyTabView *self,
                                 HdyTabPage *page)
{
  gint pos, i;

  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page));
  g_return_if_fail (page_belongs_to_this_view (self, page));

  pos = hdy_tab_view_get_page_position (self, page);

  for (i = pos - 1; i >= 0; i--) {
    HdyTabPage *p = hdy_tab_view_get_nth_page (self, i);

    hdy_tab_view_close_page (self, p);
  }
}

/**
 * hdy_tab_view_close_pages_after:
 * @self: a #HdyTabView
 * @page: a page of @self
 *
 * Requests to close all pages after @page.
 *
 * Since: 1.2
 */
void
hdy_tab_view_close_pages_after (HdyTabView *self,
                                HdyTabPage *page)
{
  gint pos, i;

  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page));
  g_return_if_fail (page_belongs_to_this_view (self, page));

  pos = hdy_tab_view_get_page_position (self, page);

  for (i = self->n_pages - 1; i > pos; i--) {
    HdyTabPage *p = hdy_tab_view_get_nth_page (self, i);

    hdy_tab_view_close_page (self, p);
  }
}

/**
 * hdy_tab_view_reorder_page:
 * @self: a #HdyTabView
 * @page: a page of @self
 * @position: the position to insert the page at, starting at 0
 *
 * Reorders @page to @position.
 *
 * It's a programmer error to try to reorder a pinned page after a non-pinned
 * one, or a non-pinned page before a pinned one.
 *
 * Returns: %TRUE if @page was moved, %FALSE otherwise
 *
 * Since: 1.2
 */
gboolean
hdy_tab_view_reorder_page (HdyTabView *self,
                           HdyTabPage *page,
                           gint        position)
{
  gint original_pos;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);
  g_return_val_if_fail (HDY_IS_TAB_PAGE (page), FALSE);
  g_return_val_if_fail (page_belongs_to_this_view (self, page), FALSE);

  if (hdy_tab_page_get_pinned (page)) {
    g_return_val_if_fail (position >= 0, FALSE);
    g_return_val_if_fail (position < self->n_pinned_pages, FALSE);
  } else {
    g_return_val_if_fail (position >= self->n_pinned_pages, FALSE);
    g_return_val_if_fail (position < self->n_pages, FALSE);
  }

  original_pos = hdy_tab_view_get_page_position (self, page);

  if (original_pos == position)
    return FALSE;

  g_object_ref (page);

  g_list_store_remove (self->pages, original_pos);
  g_list_store_insert (self->pages, position, page);

  g_object_unref (page);

  gtk_container_child_set (GTK_CONTAINER (self->stack),
                           hdy_tab_page_get_child (page),
                           "position", position,
                           NULL);

  g_signal_emit (self, signals[SIGNAL_PAGE_REORDERED], 0, page, position);

  return TRUE;
}

/**
 * hdy_tab_view_reorder_backward:
 * @self: a #HdyTabView
 * @page: a page of @self
 *
 * Reorders @page to before its previous page if possible.
 *
 * Returns: %TRUE if @page was moved, %FALSE otherwise
 *
 * Since: 1.2
 */
gboolean
hdy_tab_view_reorder_backward (HdyTabView *self,
                               HdyTabPage *page)
{
  gboolean pinned;
  gint pos, first;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);
  g_return_val_if_fail (HDY_IS_TAB_PAGE (page), FALSE);
  g_return_val_if_fail (page_belongs_to_this_view (self, page), FALSE);

  pos = hdy_tab_view_get_page_position (self, page);

  pinned = hdy_tab_page_get_pinned (page);
  first = pinned ? 0 : self->n_pinned_pages;

  if (pos <= first)
    return FALSE;

  return hdy_tab_view_reorder_page (self, page, pos - 1);
}

/**
 * hdy_tab_view_reorder_forward:
 * @self: a #HdyTabView
 * @page: a page of @self
 *
 * Reorders @page to after its next page if possible.
 *
 * Returns: %TRUE if @page was moved, %FALSE otherwise
 *
 * Since: 1.2
 */
gboolean
hdy_tab_view_reorder_forward (HdyTabView *self,
                              HdyTabPage *page)
{
  gboolean pinned;
  gint pos, last;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);
  g_return_val_if_fail (HDY_IS_TAB_PAGE (page), FALSE);
  g_return_val_if_fail (page_belongs_to_this_view (self, page), FALSE);

  pos = hdy_tab_view_get_page_position (self, page);

  pinned = hdy_tab_page_get_pinned (page);
  last = (pinned ? self->n_pinned_pages : self->n_pages) - 1;

  if (pos >= last)
    return FALSE;

  return hdy_tab_view_reorder_page (self, page, pos + 1);
}

/**
 * hdy_tab_view_reorder_first:
 * @self: a #HdyTabView
 * @page: a page of @self
 *
 * Reorders @page to the first possible position.
 *
 * Returns: %TRUE if @page was moved, %FALSE otherwise
 *
 * Since: 1.2
 */
gboolean
hdy_tab_view_reorder_first (HdyTabView *self,
                            HdyTabPage *page)
{
  gboolean pinned;
  gint pos;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);
  g_return_val_if_fail (HDY_IS_TAB_PAGE (page), FALSE);
  g_return_val_if_fail (page_belongs_to_this_view (self, page), FALSE);

  pinned = hdy_tab_page_get_pinned (page);
  pos = pinned ? 0 : self->n_pinned_pages;

  return hdy_tab_view_reorder_page (self, page, pos);
}

/**
 * hdy_tab_view_reorder_last:
 * @self: a #HdyTabView
 * @page: a page of @self
 *
 * Reorders @page to the last possible position.
 *
 * Returns: %TRUE if @page was moved, %FALSE otherwise
 *
 * Since: 1.2
 */
gboolean
hdy_tab_view_reorder_last (HdyTabView *self,
                           HdyTabPage *page)
{
  gboolean pinned;
  gint pos;

  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), FALSE);
  g_return_val_if_fail (HDY_IS_TAB_PAGE (page), FALSE);
  g_return_val_if_fail (page_belongs_to_this_view (self, page), FALSE);

  pinned = hdy_tab_page_get_pinned (page);
  pos = (pinned ? self->n_pinned_pages : self->n_pages) - 1;

  return hdy_tab_view_reorder_page (self, page, pos);
}

void
hdy_tab_view_detach_page (HdyTabView *self,
                          HdyTabPage *page)
{
  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page));
  g_return_if_fail (page_belongs_to_this_view (self, page));

  g_object_ref (page);

  begin_transfer_for_group (self);

  detach_page (self, page);
}

void
hdy_tab_view_attach_page (HdyTabView *self,
                          HdyTabPage *page,
                          gint        position)
{
  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page));
  g_return_if_fail (!page_belongs_to_this_view (self, page));
  g_return_if_fail (position >= 0);
  g_return_if_fail (position <= self->n_pages);

  attach_page (self, page, position);

  hdy_tab_view_set_selected_page (self, page);

  end_transfer_for_group (self);

  g_object_unref (page);
}

/**
 * hdy_tab_view_transfer_page:
 * @self: a #HdyTabView
 * @page: a page of @self
 * @other_view: the tab view to transfer the page to
 * @position: the position to insert the page at, starting at 0
 *
 * Transfers @page from @self to @other_view. The @page object will be reused.
 *
 * It's a programmer error to try to insert a pinned page after a non-pinned
 * one, or a non-pinned page before a pinned one.
 *
 * Since: 1.2
 */
void
hdy_tab_view_transfer_page (HdyTabView *self,
                            HdyTabPage *page,
                            HdyTabView *other_view,
                            gint        position)
{
  gboolean pinned;

  g_return_if_fail (HDY_IS_TAB_VIEW (self));
  g_return_if_fail (HDY_IS_TAB_PAGE (page));
  g_return_if_fail (HDY_IS_TAB_VIEW (other_view));
  g_return_if_fail (page_belongs_to_this_view (self, page));
  g_return_if_fail (position >= 0);
  g_return_if_fail (position <= other_view->n_pages);

  pinned = hdy_tab_page_get_pinned (page);

  g_return_if_fail (!pinned || position <= other_view->n_pinned_pages);
  g_return_if_fail (pinned || position >= other_view->n_pinned_pages);

  hdy_tab_view_detach_page (self, page);
  hdy_tab_view_attach_page (other_view, page, position);
}

/**
 * hdy_tab_view_get_pages:
 * @self: a #HdyTabView
 *
 * Returns a #GListModel containing the pages of @self. This model can be used
 * to keep an up to date view of the pages.
 *
 * Returns: (transfer none): the model containing pages of @self
 *
 * Since: 1.2
 */
GListModel *
hdy_tab_view_get_pages (HdyTabView *self)
{
  g_return_val_if_fail (HDY_IS_TAB_VIEW (self), NULL);

  return G_LIST_MODEL (self->pages);
}

HdyTabView *
hdy_tab_view_create_window (HdyTabView *self)
{
  HdyTabView *new_view = NULL;

  g_signal_emit (self, signals[SIGNAL_CREATE_WINDOW], 0, &new_view);

  if (!new_view) {
    g_critical ("HdyTabView::create-window handler must not return NULL");

    return NULL;
  }

  new_view->transfer_count = self->transfer_count;

  return new_view;
}
