/*
 * Copyright (C) 2020 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1+
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#pragma once

#if !defined(_HANDY_INSIDE) && !defined(HANDY_COMPILATION)
#error "Only <handy.h> can be included directly."
#endif

#include "hdy-version.h"

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define HDY_TYPE_TAB_PAGE (hdy_tab_page_get_type())

HDY_AVAILABLE_IN_1_2
G_DECLARE_FINAL_TYPE (HdyTabPage, hdy_tab_page, HDY, TAB_PAGE, GObject)

HDY_AVAILABLE_IN_1_2
GtkWidget *hdy_tab_page_get_child (HdyTabPage *self);

HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_page_get_parent (HdyTabPage *self);

HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_page_get_selected (HdyTabPage *self);

HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_page_get_pinned (HdyTabPage *self);

HDY_AVAILABLE_IN_1_2
const gchar *hdy_tab_page_get_title (HdyTabPage  *self);
HDY_AVAILABLE_IN_1_2
void         hdy_tab_page_set_title (HdyTabPage  *self,
                                     const gchar *title);

HDY_AVAILABLE_IN_1_2
const gchar *hdy_tab_page_get_tooltip (HdyTabPage  *self);
HDY_AVAILABLE_IN_1_2
void         hdy_tab_page_set_tooltip (HdyTabPage  *self,
                                       const gchar *tooltip);

HDY_AVAILABLE_IN_1_2
GIcon *hdy_tab_page_get_icon (HdyTabPage *self);
HDY_AVAILABLE_IN_1_2
void   hdy_tab_page_set_icon (HdyTabPage *self,
                              GIcon      *icon);

HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_page_get_loading (HdyTabPage *self);
HDY_AVAILABLE_IN_1_2
void     hdy_tab_page_set_loading (HdyTabPage *self,
                                   gboolean    loading);

HDY_AVAILABLE_IN_1_2
GIcon *hdy_tab_page_get_indicator_icon (HdyTabPage *self);
HDY_AVAILABLE_IN_1_2
void   hdy_tab_page_set_indicator_icon (HdyTabPage *self,
                                        GIcon      *indicator_icon);

HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_page_get_indicator_activatable (HdyTabPage *self);
HDY_AVAILABLE_IN_1_2
void     hdy_tab_page_set_indicator_activatable (HdyTabPage *self,
                                                 gboolean    activatable);

HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_page_get_needs_attention (HdyTabPage *self);
HDY_AVAILABLE_IN_1_2
void     hdy_tab_page_set_needs_attention (HdyTabPage *self,
                                           gboolean    needs_attention);

#define HDY_TYPE_TAB_VIEW (hdy_tab_view_get_type())

HDY_AVAILABLE_IN_1_2
G_DECLARE_FINAL_TYPE (HdyTabView, hdy_tab_view, HDY, TAB_VIEW, GtkBin)

HDY_AVAILABLE_IN_1_2
HdyTabView *hdy_tab_view_new (void);

HDY_AVAILABLE_IN_1_2
gint hdy_tab_view_get_n_pages (HdyTabView *self);
HDY_AVAILABLE_IN_1_2
gint hdy_tab_view_get_n_pinned_pages (HdyTabView *self);

HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_view_get_is_transferring_page (HdyTabView *self);

HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_get_selected_page (HdyTabView *self);
HDY_AVAILABLE_IN_1_2
void        hdy_tab_view_set_selected_page (HdyTabView *self,
                                            HdyTabPage *selected_page);

HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_view_select_previous_page (HdyTabView *self);
HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_view_select_next_page     (HdyTabView *self);

HDY_AVAILABLE_IN_1_2
GIcon *hdy_tab_view_get_default_icon (HdyTabView *self);
HDY_AVAILABLE_IN_1_2
void   hdy_tab_view_set_default_icon (HdyTabView *self,
                                      GIcon      *default_icon);

HDY_AVAILABLE_IN_1_2
GMenuModel *hdy_tab_view_get_menu_model (HdyTabView *self);
HDY_AVAILABLE_IN_1_2
void        hdy_tab_view_set_menu_model (HdyTabView *self,
                                         GMenuModel *menu_model);

HDY_AVAILABLE_IN_1_2
GtkWidget *hdy_tab_view_get_shortcut_widget (HdyTabView *self);
HDY_AVAILABLE_IN_1_2
void       hdy_tab_view_set_shortcut_widget (HdyTabView *self,
                                             GtkWidget  *widget);

HDY_AVAILABLE_IN_1_2
void hdy_tab_view_set_page_pinned (HdyTabView *self,
                                   HdyTabPage *page,
                                   gboolean    pinned);

HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_get_page (HdyTabView *self,
                                   GtkWidget  *child);

HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_get_nth_page (HdyTabView *self,
                                       gint        position);

HDY_AVAILABLE_IN_1_2
gint hdy_tab_view_get_page_position (HdyTabView *self,
                                     HdyTabPage *page);

HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_add_page (HdyTabView *self,
                                   GtkWidget  *child,
                                   HdyTabPage *parent);

HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_insert  (HdyTabView *self,
                                  GtkWidget  *child,
                                  gint        position);
HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_prepend (HdyTabView *self,
                                  GtkWidget  *child);
HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_append  (HdyTabView *self,
                                  GtkWidget  *child);

HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_insert_pinned  (HdyTabView *self,
                                         GtkWidget  *child,
                                         gint        position);
HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_prepend_pinned (HdyTabView *self,
                                         GtkWidget  *child);
HDY_AVAILABLE_IN_1_2
HdyTabPage *hdy_tab_view_append_pinned  (HdyTabView *self,
                                         GtkWidget  *child);

HDY_AVAILABLE_IN_1_2
void hdy_tab_view_close_page        (HdyTabView *self,
                                     HdyTabPage *page);
HDY_AVAILABLE_IN_1_2
void hdy_tab_view_close_page_finish (HdyTabView *self,
                                     HdyTabPage *page,
                                     gboolean    confirm);

HDY_AVAILABLE_IN_1_2
void hdy_tab_view_close_other_pages  (HdyTabView *self,
                                      HdyTabPage *page);
HDY_AVAILABLE_IN_1_2
void hdy_tab_view_close_pages_before (HdyTabView *self,
                                      HdyTabPage *page);
HDY_AVAILABLE_IN_1_2
void hdy_tab_view_close_pages_after  (HdyTabView *self,
                                      HdyTabPage *page);

HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_view_reorder_page     (HdyTabView *self,
                                        HdyTabPage *page,
                                        gint        position);
HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_view_reorder_backward (HdyTabView *self,
                                        HdyTabPage *page);
HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_view_reorder_forward  (HdyTabView *self,
                                        HdyTabPage *page);
HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_view_reorder_first    (HdyTabView *self,
                                        HdyTabPage *page);
HDY_AVAILABLE_IN_1_2
gboolean hdy_tab_view_reorder_last     (HdyTabView *self,
                                        HdyTabPage *page);

HDY_AVAILABLE_IN_1_2
void hdy_tab_view_transfer_page (HdyTabView *self,
                                 HdyTabPage *page,
                                 HdyTabView *other_view,
                                 gint        position);

HDY_AVAILABLE_IN_1_2
GListModel *hdy_tab_view_get_pages (HdyTabView *self);

G_END_DECLS
