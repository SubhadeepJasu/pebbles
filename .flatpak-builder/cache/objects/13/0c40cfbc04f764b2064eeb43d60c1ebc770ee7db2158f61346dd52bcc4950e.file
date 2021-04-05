/*
 * Copyright (C) 2021 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1+
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#pragma once

#if !defined(_HANDY_INSIDE) && !defined(HANDY_COMPILATION)
#error "Only <handy.h> can be included directly."
#endif

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define HDY_TYPE_FADING_LABEL (hdy_fading_label_get_type())

G_DECLARE_FINAL_TYPE (HdyFadingLabel, hdy_fading_label, HDY, FADING_LABEL, GtkBin)

const gchar *hdy_fading_label_get_label (HdyFadingLabel *self);
void         hdy_fading_label_set_label (HdyFadingLabel *self,
                                         const gchar    *label);

float        hdy_fading_label_get_align (HdyFadingLabel *self);
void         hdy_fading_label_set_align (HdyFadingLabel *self,
                                         gfloat          align);

G_END_DECLS
