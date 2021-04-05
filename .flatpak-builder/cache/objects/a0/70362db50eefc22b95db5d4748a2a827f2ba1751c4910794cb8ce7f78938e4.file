/*
 * Copyright (C) 2019 Alexander Mikhaylenko <exalm7659@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.1+
 */

#include "config.h"
#include <glib/gi18n-lib.h>

#include "hdy-swipe-tracker-private.h"
#include "hdy-navigation-direction.h"

#include <math.h>

#define TOUCHPAD_BASE_DISTANCE_H 400
#define TOUCHPAD_BASE_DISTANCE_V 300
#define EVENT_HISTORY_THRESHOLD_MS 150
#define SCROLL_MULTIPLIER 10
#define MIN_ANIMATION_DURATION 100
#define MAX_ANIMATION_DURATION 400
#define VELOCITY_THRESHOLD_TOUCH 0.3
#define VELOCITY_THRESHOLD_TOUCHPAD 0.6
#define DECELERATION_TOUCH 0.998
#define DECELERATION_TOUCHPAD 0.997
#define VELOCITY_CURVE_THRESHOLD 2
#define DECELERATION_PARABOLA_MULTIPLIER 0.35
#define DURATION_MULTIPLIER 3
#define ANIMATION_BASE_VELOCITY 0.002
#define DRAG_THRESHOLD_DISTANCE 16
#define EPSILON 0.005

#define SIGN(x) ((x) > 0.0 ? 1.0 : ((x) < 0.0 ? -1.0 : 0.0))

/**
 * SECTION:hdy-swipe-tracker
 * @short_description: Swipe tracker used in #HdyCarousel and #HdyLeaflet
 * @title: HdySwipeTracker
 * @See_also: #HdyCarousel, #HdyDeck, #HdyLeaflet, #HdySwipeable
 *
 * The HdySwipeTracker object can be used for implementing widgets with swipe
 * gestures. It supports touch-based swipes, pointer dragging, and touchpad
 * scrolling.
 *
 * The widgets will probably want to expose #HdySwipeTracker:enabled property.
 * If they expect to use horizontal orientation, #HdySwipeTracker:reversed
 * property can be used for supporting RTL text direction.
 *
 * Since: 1.0
 */

typedef enum {
  HDY_SWIPE_TRACKER_STATE_NONE,
  HDY_SWIPE_TRACKER_STATE_PENDING,
  HDY_SWIPE_TRACKER_STATE_SCROLLING,
  HDY_SWIPE_TRACKER_STATE_FINISHING,
  HDY_SWIPE_TRACKER_STATE_REJECTED,
} HdySwipeTrackerState;

typedef struct {
  gdouble delta;
  guint32 time;
} EventHistoryRecord;

struct _HdySwipeTracker
{
  GObject parent_instance;

  HdySwipeable *swipeable;
  gboolean enabled;
  gboolean reversed;
  gboolean allow_mouse_drag;
  gboolean allow_long_swipes;
  GtkOrientation orientation;

  GArray *event_history;

  gint start_x;
  gint start_y;
  gboolean use_capture_phase;

  gdouble initial_progress;
  gdouble progress;
  gboolean cancelled;

  gdouble prev_offset;

  gboolean is_scrolling;

  HdySwipeTrackerState state;
  GtkGesture *touch_gesture;
};

G_DEFINE_TYPE_WITH_CODE (HdySwipeTracker, hdy_swipe_tracker, G_TYPE_OBJECT,
                         G_IMPLEMENT_INTERFACE (GTK_TYPE_ORIENTABLE, NULL));

enum {
  PROP_0,
  PROP_SWIPEABLE,
  PROP_ENABLED,
  PROP_REVERSED,
  PROP_ALLOW_MOUSE_DRAG,
  PROP_ALLOW_LONG_SWIPES,

  /* GtkOrientable */
  PROP_ORIENTATION,
  LAST_PROP = PROP_ALLOW_LONG_SWIPES + 1,
};

static GParamSpec *props[LAST_PROP];

enum {
  SIGNAL_BEGIN_SWIPE,
  SIGNAL_UPDATE_SWIPE,
  SIGNAL_END_SWIPE,
  SIGNAL_LAST_SIGNAL,
};

static guint signals[SIGNAL_LAST_SIGNAL];

static gboolean
get_widget_coordinates (HdySwipeTracker *self,
                        GdkEvent        *event,
                        gdouble         *x,
                        gdouble         *y)
{
  GdkWindow *window = gdk_event_get_window (event);
  gdouble tx, ty, out_x = -1, out_y = -1;

  if (!gdk_event_get_coords (event, &tx, &ty))
    goto out;

  while (window && window != gtk_widget_get_window (GTK_WIDGET (self->swipeable))) {
    gint window_x, window_y;

    gdk_window_get_position (window, &window_x, &window_y);

    tx += window_x;
    ty += window_y;

    window = gdk_window_get_parent (window);
  }

  if (window) {
    out_x = tx;
    out_y = ty;
    goto out;
  }

out:
  if (x)
    *x = out_x;

  if (y)
    *y = out_y;

  return out_x >= 0 && out_y >= 0;
}

static void
reset (HdySwipeTracker *self)
{
  self->state = HDY_SWIPE_TRACKER_STATE_NONE;

  self->prev_offset = 0;

  self->initial_progress = 0;
  self->progress = 0;

  g_array_remove_range (self->event_history, 0, self->event_history->len);

  self->start_x = 0;
  self->start_y = 0;
  self->use_capture_phase = FALSE;

  self->cancelled = FALSE;

  if (self->swipeable)
    gtk_grab_remove (GTK_WIDGET (self->swipeable));
}

static void
get_range (HdySwipeTracker *self,
           gdouble         *first,
           gdouble         *last)
{
  g_autofree gdouble *points = NULL;
  gint n;

  points = hdy_swipeable_get_snap_points (self->swipeable, &n);

  *first = points[0];
  *last = points[n - 1];
}

static void
gesture_prepare (HdySwipeTracker        *self,
                 HdyNavigationDirection  direction,
                 gboolean                is_drag)
{
  GdkRectangle rect;

  if (self->state != HDY_SWIPE_TRACKER_STATE_NONE)
    return;

  hdy_swipeable_get_swipe_area (self->swipeable, direction, is_drag, &rect);

  if (self->start_x < rect.x ||
      self->start_x >= rect.x + rect.width ||
      self->start_y < rect.y ||
      self->start_y >= rect.y + rect.height) {
    self->state = HDY_SWIPE_TRACKER_STATE_REJECTED;

    return;
  }

  hdy_swipe_tracker_emit_begin_swipe (self, direction, TRUE);

  self->initial_progress = hdy_swipeable_get_progress (self->swipeable);
  self->progress = self->initial_progress;
  self->state = HDY_SWIPE_TRACKER_STATE_PENDING;
}

static void
trim_history (HdySwipeTracker *self)
{
  g_autoptr (GdkEvent) event = gtk_get_current_event ();
  guint32 threshold_time = gdk_event_get_time (event) - EVENT_HISTORY_THRESHOLD_MS;
  guint i;

  for (i = 0; i < self->event_history->len; i++) {
    guint32 time = g_array_index (self->event_history,
                                  EventHistoryRecord, i).time;

    if (time >= threshold_time)
      break;
  }

  if (i > 0)
    g_array_remove_range (self->event_history, 0, i);
}

static void
append_to_history (HdySwipeTracker *self,
                   gdouble          delta)
{
  g_autoptr (GdkEvent) event = gtk_get_current_event ();
  EventHistoryRecord record;

  trim_history (self);

  record.delta = delta;
  record.time = gdk_event_get_time (event);

  g_array_append_val (self->event_history, record);
}

static gdouble
calculate_velocity (HdySwipeTracker *self)
{
  gdouble total_delta = 0;
  guint32 first_time = 0, last_time = 0;
  guint i;

  for (i = 0; i < self->event_history->len; i++) {
    EventHistoryRecord *r =
      &g_array_index (self->event_history, EventHistoryRecord, i);

    if (i == 0)
      first_time = r->time;
    else
      total_delta += r->delta;

    last_time = r->time;
  }

  if (first_time == last_time)
    return 0;

  return total_delta / (last_time - first_time);
}

static void
gesture_begin (HdySwipeTracker *self)
{
  if (self->state != HDY_SWIPE_TRACKER_STATE_PENDING)
    return;

  self->state = HDY_SWIPE_TRACKER_STATE_SCROLLING;

  gtk_grab_add (GTK_WIDGET (self->swipeable));
}

static gint
find_closest_point (gdouble *points,
                    gint     n,
                    gdouble  pos)
{
  guint i, min = 0;

  for (i = 1; i < n; i++)
    if (ABS (points[i] - pos) < ABS (points[min] - pos))
      min = i;

  return min;
}

static gint
find_next_point (gdouble *points,
                 gint     n,
                 gdouble  pos)
{
  guint i;

  for (i = 0; i < n; i++)
    if (points[i] >= pos)
      return i;

  return -1;
}

static gint
find_previous_point (gdouble *points,
                     gint     n,
                     gdouble  pos)
{
  gint i;

  for (i = n - 1; i >= 0; i--)
    if (points[i] <= pos)
      return i;

  return -1;
}

static gint
find_point_for_projection (HdySwipeTracker *self,
                           gdouble         *points,
                           gint             n,
                           gdouble          pos,
                           gdouble          velocity)
{
  gint initial = find_closest_point (points, n, self->initial_progress);
  gint prev = find_previous_point (points, n, pos);
  gint next = find_next_point (points, n, pos);

  if ((velocity > 0 ? prev : next) == initial)
    return velocity > 0 ? next : prev;

  return find_closest_point (points, n, pos);
}

static void
get_bounds (HdySwipeTracker *self,
            gdouble         *points,
            gint             n,
            gdouble          pos,
            gdouble         *lower,
            gdouble         *upper)
{
  gint prev, next;
  gint closest = find_closest_point (points, n, pos);

  if (ABS (points[closest] - pos) < EPSILON) {
    prev = next = closest;
  } else {
    prev = find_previous_point (points, n, pos);
    next = find_next_point (points, n, pos);
  }

  *lower = points[MAX (prev - 1, 0)];
  *upper = points[MIN (next + 1, n - 1)];
}

static void
gesture_update (HdySwipeTracker *self,
                gdouble          delta)
{
  gdouble lower, upper;
  gdouble progress;

  if (self->state != HDY_SWIPE_TRACKER_STATE_SCROLLING)
    return;

  if (!self->allow_long_swipes) {
    g_autofree gdouble *points = NULL;
    gint n;

    points = hdy_swipeable_get_snap_points (self->swipeable, &n);
    get_bounds (self, points, n, self->initial_progress, &lower, &upper);
  } else {
    get_range (self, &lower, &upper);
  }

  progress = self->progress + delta;
  progress = CLAMP (progress, lower, upper);

  self->progress = progress;

  hdy_swipe_tracker_emit_update_swipe (self, progress);
}

static gdouble
get_end_progress (HdySwipeTracker *self,
                  gdouble          velocity,
                  gboolean         is_touchpad)
{
  gdouble pos, decel, slope;
  g_autofree gdouble *points = NULL;
  gint n;
  gdouble lower, upper;

  if (self->cancelled)
    return hdy_swipeable_get_cancel_progress (self->swipeable);

  points = hdy_swipeable_get_snap_points (self->swipeable, &n);

  if (ABS (velocity) < (is_touchpad ? VELOCITY_THRESHOLD_TOUCHPAD : VELOCITY_THRESHOLD_TOUCH))
    return points[find_closest_point (points, n, self->progress)];

  decel = is_touchpad ? DECELERATION_TOUCHPAD : DECELERATION_TOUCH;
  slope = decel / (1.0 - decel) / 1000.0;

  if (ABS (velocity) > VELOCITY_CURVE_THRESHOLD) {
    const gdouble c = slope / 2 / DECELERATION_PARABOLA_MULTIPLIER;
    const gdouble x = ABS (velocity) - VELOCITY_CURVE_THRESHOLD + c;

    pos = DECELERATION_PARABOLA_MULTIPLIER * x * x
        - DECELERATION_PARABOLA_MULTIPLIER * c * c
        + slope * VELOCITY_CURVE_THRESHOLD;
  } else {
    pos = ABS (velocity) * slope;
  }

  pos = (pos * SIGN (velocity)) + self->progress;

  if (!self->allow_long_swipes) {

    get_bounds (self, points, n, self->initial_progress, &lower, &upper);
  } else {
    get_range (self, &lower, &upper);
  }

  pos = CLAMP (pos, lower, upper);
  pos = points[find_point_for_projection (self, points, n, pos, velocity)];

  return pos;
}

static void
gesture_end (HdySwipeTracker *self,
             gdouble          distance,
             gboolean         is_touchpad)
{
  gdouble end_progress, velocity;
  gint64 duration, max_duration;

  if (self->state == HDY_SWIPE_TRACKER_STATE_NONE)
    return;

  trim_history (self);

  velocity = calculate_velocity (self);

  end_progress = get_end_progress (self, velocity, is_touchpad);

  velocity /= distance;

  if ((end_progress - self->progress) * velocity <= 0)
    velocity = ANIMATION_BASE_VELOCITY;

  max_duration = MAX_ANIMATION_DURATION * log2 (1 + MAX (1, ceil (ABS (self->progress - end_progress))));

  duration = ABS ((self->progress - end_progress) / velocity * DURATION_MULTIPLIER);
  if (self->progress != end_progress)
    duration = CLAMP (duration, MIN_ANIMATION_DURATION, max_duration);

  hdy_swipe_tracker_emit_end_swipe (self, duration, end_progress);

  if (self->cancelled)
    reset (self);
  else
    self->state = HDY_SWIPE_TRACKER_STATE_FINISHING;
}

static void
gesture_cancel (HdySwipeTracker *self,
                gdouble          distance,
                gboolean         is_touchpad)
{
  if (self->state != HDY_SWIPE_TRACKER_STATE_PENDING &&
      self->state != HDY_SWIPE_TRACKER_STATE_SCROLLING) {
    reset (self);

    return;
  }

  self->cancelled = TRUE;
  gesture_end (self, distance, is_touchpad);
}

static void
drag_begin_cb (HdySwipeTracker *self,
               gdouble          start_x,
               gdouble          start_y,
               GtkGestureDrag  *gesture)
{
  if (self->state != HDY_SWIPE_TRACKER_STATE_NONE)
    gtk_gesture_set_state (self->touch_gesture, GTK_EVENT_SEQUENCE_DENIED);

  self->start_x = start_x;
  self->start_y = start_y;
}

static void
drag_update_cb (HdySwipeTracker *self,
                gdouble          offset_x,
                gdouble          offset_y,
                GtkGestureDrag  *gesture)
{
  gdouble offset, distance, delta;
  gboolean is_vertical, is_offset_vertical;

  distance = hdy_swipeable_get_distance (self->swipeable);

  is_vertical = (self->orientation == GTK_ORIENTATION_VERTICAL);
  offset = is_vertical ? offset_y : offset_x;

  if (!self->reversed)
    offset = -offset;

  delta = offset - self->prev_offset;
  self->prev_offset = offset;

  is_offset_vertical = (ABS (offset_y) > ABS (offset_x));

  if (self->state == HDY_SWIPE_TRACKER_STATE_REJECTED) {
    gtk_gesture_set_state (self->touch_gesture, GTK_EVENT_SEQUENCE_DENIED);
    return;
  }

  append_to_history (self, delta);

  if (self->state == HDY_SWIPE_TRACKER_STATE_NONE) {
    if (is_vertical == is_offset_vertical)
      gesture_prepare (self, offset > 0 ? HDY_NAVIGATION_DIRECTION_FORWARD : HDY_NAVIGATION_DIRECTION_BACK, TRUE);
    else
      gtk_gesture_set_state (self->touch_gesture, GTK_EVENT_SEQUENCE_DENIED);
    return;
  }

  if (self->state == HDY_SWIPE_TRACKER_STATE_PENDING) {
    gdouble drag_distance;
    gdouble first_point, last_point;
    gboolean is_overshooting;

    get_range (self, &first_point, &last_point);

    drag_distance = sqrt (offset_x * offset_x + offset_y * offset_y);
    is_overshooting = (offset < 0 && self->progress <= first_point) ||
                      (offset > 0 && self->progress >= last_point);

    if (drag_distance >= DRAG_THRESHOLD_DISTANCE) {
      if ((is_vertical == is_offset_vertical) && !is_overshooting) {
        gesture_begin (self);
        self->prev_offset = offset;
        gtk_gesture_set_state (self->touch_gesture, GTK_EVENT_SEQUENCE_CLAIMED);
      } else {
        gtk_gesture_set_state (self->touch_gesture, GTK_EVENT_SEQUENCE_DENIED);
      }
    }
  }

  if (self->state == HDY_SWIPE_TRACKER_STATE_SCROLLING)
    gesture_update (self, delta / distance);
}

static void
drag_end_cb (HdySwipeTracker *self,
             gdouble          offset_x,
             gdouble          offset_y,
             GtkGestureDrag  *gesture)
{
  gdouble distance;

  distance = hdy_swipeable_get_distance (self->swipeable);

  if (self->state == HDY_SWIPE_TRACKER_STATE_REJECTED) {
    gtk_gesture_set_state (self->touch_gesture, GTK_EVENT_SEQUENCE_DENIED);

    reset (self);
    return;
  }

  if (self->state != HDY_SWIPE_TRACKER_STATE_SCROLLING) {
    gesture_cancel (self, distance, FALSE);
    gtk_gesture_set_state (self->touch_gesture, GTK_EVENT_SEQUENCE_DENIED);
    return;
  }

  gesture_end (self, distance, FALSE);
}

static void
drag_cancel_cb (HdySwipeTracker  *self,
                GdkEventSequence *sequence,
                GtkGesture       *gesture)
{
  gdouble distance;

  distance = hdy_swipeable_get_distance (self->swipeable);

  gesture_cancel (self, distance, FALSE);
  gtk_gesture_set_state (gesture, GTK_EVENT_SEQUENCE_DENIED);
}

static gboolean
handle_scroll_event (HdySwipeTracker *self,
                     GdkEvent        *event,
                     gboolean         capture)
{
  GdkDevice *source_device;
  GdkInputSource input_source;
  gdouble dx, dy, delta, distance;
  gboolean is_vertical;
  gboolean is_delta_vertical;

  is_vertical = (self->orientation == GTK_ORIENTATION_VERTICAL);
  distance = is_vertical ? TOUCHPAD_BASE_DISTANCE_V : TOUCHPAD_BASE_DISTANCE_H;

  if (gdk_event_get_scroll_direction (event, NULL))
    return GDK_EVENT_PROPAGATE;

  source_device = gdk_event_get_source_device (event);
  input_source = gdk_device_get_source (source_device);
  if (input_source != GDK_SOURCE_TOUCHPAD)
    return GDK_EVENT_PROPAGATE;

  gdk_event_get_scroll_deltas (event, &dx, &dy);
  delta = is_vertical ? dy : dx;
  if (self->reversed)
    delta = -delta;

  is_delta_vertical = (ABS (dy) > ABS (dx));

  if (self->is_scrolling) {
    gesture_cancel (self, distance, TRUE);

    if (gdk_event_is_scroll_stop_event (event))
      self->is_scrolling = FALSE;

    return GDK_EVENT_PROPAGATE;
  }

  if (self->state == HDY_SWIPE_TRACKER_STATE_REJECTED) {
    if (gdk_event_is_scroll_stop_event (event))
      reset (self);

    return GDK_EVENT_PROPAGATE;
  }

  if (self->state == HDY_SWIPE_TRACKER_STATE_NONE) {
    if (gdk_event_is_scroll_stop_event (event))
      return GDK_EVENT_PROPAGATE;

    if (is_vertical == is_delta_vertical) {
      if (!capture) {
        gdouble event_x, event_y;

        get_widget_coordinates (self, event, &event_x, &event_y);

        self->start_x = (gint) round (event_x);
        self->start_y = (gint) round (event_y);

        gesture_prepare (self, delta > 0 ? HDY_NAVIGATION_DIRECTION_FORWARD : HDY_NAVIGATION_DIRECTION_BACK, FALSE);
      }
    } else {
      self->is_scrolling = TRUE;
      return GDK_EVENT_PROPAGATE;
    }
  }

  if (!capture && self->state == HDY_SWIPE_TRACKER_STATE_PENDING) {
    gboolean is_overshooting;
    gdouble first_point, last_point;

    get_range (self, &first_point, &last_point);

    is_overshooting = (delta < 0 && self->progress <= first_point) ||
                      (delta > 0 && self->progress >= last_point);

    append_to_history (self, delta * SCROLL_MULTIPLIER);

    if ((is_vertical == is_delta_vertical) && !is_overshooting)
      gesture_begin (self);
    else
      gesture_cancel (self, distance, TRUE);
  }

  if (self->state == HDY_SWIPE_TRACKER_STATE_SCROLLING) {
    if (gdk_event_is_scroll_stop_event (event)) {
      gesture_end (self, distance, TRUE);
    } else {
      append_to_history (self, delta * SCROLL_MULTIPLIER);

      gesture_update (self, delta / distance * SCROLL_MULTIPLIER);
      return GDK_EVENT_STOP;
    }
  }

  if (!capture && self->state == HDY_SWIPE_TRACKER_STATE_FINISHING)
    reset (self);

  return GDK_EVENT_PROPAGATE;
}

static gboolean
is_window_handle (GtkWidget *widget)
{
  gboolean window_dragging;
  GtkWidget *parent, *window, *titlebar;

  gtk_widget_style_get (widget, "window-dragging", &window_dragging, NULL);

  if (window_dragging)
    return TRUE;

  /* Window titlebar area is always draggable, so check if we're inside. */
  window = gtk_widget_get_toplevel (widget);
  if (!GTK_IS_WINDOW (window))
    return FALSE;

  titlebar = gtk_window_get_titlebar (GTK_WINDOW (window));
  if (!titlebar)
    return FALSE;

  parent = widget;
  while (parent && parent != titlebar)
    parent = gtk_widget_get_parent (parent);

  return parent == titlebar;
}

static gboolean
has_conflicts (HdySwipeTracker *self,
               GtkWidget       *widget)
{
  HdySwipeTracker *other;

  if (widget == GTK_WIDGET (self->swipeable))
    return TRUE;

  if (!HDY_IS_SWIPEABLE (widget))
    return FALSE;

  other = hdy_swipeable_get_swipe_tracker (HDY_SWIPEABLE (widget));

  return self->orientation == other->orientation;
}

/* HACK: Since we don't have _gtk_widget_consumes_motion(), we can't do a proper
 * check for whether we can drag from a widget or not. So we trust the widgets
 * to propagate or stop their events. However, GtkButton stops press events,
 * making it impossible to drag from it.
 */
static gboolean
should_force_drag (HdySwipeTracker *self,
                   GtkWidget       *widget)
{
  GtkWidget *parent;

  if (!GTK_IS_BUTTON (widget))
    return FALSE;

  parent = widget;
  while (parent && !has_conflicts (self, parent))
    parent = gtk_widget_get_parent (parent);

  return parent == GTK_WIDGET (self->swipeable);
}

static gboolean
handle_event_cb (HdySwipeTracker *self,
                 GdkEvent        *event)
{
  GdkEventSequence *sequence;
  gboolean retval;
  GtkEventSequenceState state;
  GtkWidget *widget;

  if (!self->enabled && self->state != HDY_SWIPE_TRACKER_STATE_SCROLLING)
    return GDK_EVENT_PROPAGATE;

  if (self->use_capture_phase)
    return GDK_EVENT_PROPAGATE;

  if (event->type == GDK_SCROLL)
    return handle_scroll_event (self, event, FALSE);

  if (event->type != GDK_BUTTON_PRESS &&
      event->type != GDK_BUTTON_RELEASE &&
      event->type != GDK_MOTION_NOTIFY &&
      event->type != GDK_TOUCH_BEGIN &&
      event->type != GDK_TOUCH_END &&
      event->type != GDK_TOUCH_UPDATE &&
      event->type != GDK_TOUCH_CANCEL)
    return GDK_EVENT_PROPAGATE;

  widget = gtk_get_event_widget (event);
  if (is_window_handle (widget))
    return GDK_EVENT_PROPAGATE;

  sequence = gdk_event_get_event_sequence (event);
  retval = gtk_event_controller_handle_event (GTK_EVENT_CONTROLLER (self->touch_gesture), event);
  state = gtk_gesture_get_sequence_state (self->touch_gesture, sequence);

  if (state == GTK_EVENT_SEQUENCE_DENIED) {
    gtk_event_controller_reset (GTK_EVENT_CONTROLLER (self->touch_gesture));
    return GDK_EVENT_PROPAGATE;
  }

  if (self->state == HDY_SWIPE_TRACKER_STATE_SCROLLING) {
    return GDK_EVENT_STOP;
  } else if (self->state == HDY_SWIPE_TRACKER_STATE_FINISHING) {
    reset (self);
    return GDK_EVENT_STOP;
  }
  return retval;
}

static gboolean
captured_event_cb (HdySwipeable *swipeable,
                   GdkEvent     *event)
{
  HdySwipeTracker *self = hdy_swipeable_get_swipe_tracker (swipeable);
  GtkWidget *widget;
  GdkEventSequence *sequence;
  gboolean retval;
  GtkEventSequenceState state;

  g_assert (HDY_IS_SWIPE_TRACKER (self));

  if (!self->enabled && self->state != HDY_SWIPE_TRACKER_STATE_SCROLLING)
    return GDK_EVENT_PROPAGATE;

  if (event->type == GDK_SCROLL)
    return handle_scroll_event (self, event, TRUE);

  if (event->type != GDK_BUTTON_PRESS &&
      event->type != GDK_BUTTON_RELEASE &&
      event->type != GDK_MOTION_NOTIFY &&
      event->type != GDK_TOUCH_BEGIN &&
      event->type != GDK_TOUCH_END &&
      event->type != GDK_TOUCH_UPDATE &&
      event->type != GDK_TOUCH_CANCEL)
    return GDK_EVENT_PROPAGATE;

  widget = gtk_get_event_widget (event);

  if (!self->use_capture_phase && !should_force_drag (self, widget))
    return GDK_EVENT_PROPAGATE;

  sequence = gdk_event_get_event_sequence (event);

  if (gtk_gesture_handles_sequence (self->touch_gesture, sequence))
    self->use_capture_phase = TRUE;

  retval = gtk_event_controller_handle_event (GTK_EVENT_CONTROLLER (self->touch_gesture), event);
  state = gtk_gesture_get_sequence_state (self->touch_gesture, sequence);

  if (state == GTK_EVENT_SEQUENCE_DENIED) {
    gtk_event_controller_reset (GTK_EVENT_CONTROLLER (self->touch_gesture));
    return GDK_EVENT_PROPAGATE;
  }

  if (self->state == HDY_SWIPE_TRACKER_STATE_SCROLLING) {
    return GDK_EVENT_STOP;
  } else if (self->state == HDY_SWIPE_TRACKER_STATE_FINISHING) {
    reset (self);
    return GDK_EVENT_STOP;
  }

  return retval;
}

static void
hdy_swipe_tracker_constructed (GObject *object)
{
  HdySwipeTracker *self = HDY_SWIPE_TRACKER (object);

  g_assert (self->swipeable);

  gtk_widget_add_events (GTK_WIDGET (self->swipeable),
                         GDK_SMOOTH_SCROLL_MASK |
                         GDK_BUTTON_PRESS_MASK |
                         GDK_BUTTON_RELEASE_MASK |
                         GDK_BUTTON_MOTION_MASK |
                         GDK_TOUCH_MASK);

  self->touch_gesture = g_object_new (GTK_TYPE_GESTURE_DRAG,
                                      "widget", self->swipeable,
                                      "propagation-phase", GTK_PHASE_NONE,
                                      "touch-only", !self->allow_mouse_drag,
                                      NULL);

  g_signal_connect_swapped (self->touch_gesture, "drag-begin", G_CALLBACK (drag_begin_cb), self);
  g_signal_connect_swapped (self->touch_gesture, "drag-update", G_CALLBACK (drag_update_cb), self);
  g_signal_connect_swapped (self->touch_gesture, "drag-end", G_CALLBACK (drag_end_cb), self);
  g_signal_connect_swapped (self->touch_gesture, "cancel", G_CALLBACK (drag_cancel_cb), self);

  g_signal_connect_object (self->swipeable, "event", G_CALLBACK (handle_event_cb), self, G_CONNECT_SWAPPED);
  g_signal_connect_object (self->swipeable, "unrealize", G_CALLBACK (reset), self, G_CONNECT_SWAPPED);

  /*
   * HACK: GTK3 has no other way to get events on capture phase.
   * This is a reimplementation of _gtk_widget_set_captured_event_handler(),
   * which is private. In GTK4 it can be replaced with GtkEventControllerLegacy
   * with capture propagation phase
   */
  g_object_set_data (G_OBJECT (self->swipeable), "captured-event-handler", captured_event_cb);

  G_OBJECT_CLASS (hdy_swipe_tracker_parent_class)->constructed (object);
}

static void
hdy_swipe_tracker_dispose (GObject *object)
{
  HdySwipeTracker *self = HDY_SWIPE_TRACKER (object);

  if (self->swipeable)
    gtk_grab_remove (GTK_WIDGET (self->swipeable));

  if (self->touch_gesture)
    g_signal_handlers_disconnect_by_data (self->touch_gesture, self);

  g_object_set_data (G_OBJECT (self->swipeable), "captured-event-handler", NULL);

  g_clear_object (&self->touch_gesture);
  g_clear_object (&self->swipeable);

  G_OBJECT_CLASS (hdy_swipe_tracker_parent_class)->dispose (object);
}

static void
hdy_swipe_tracker_get_property (GObject    *object,
                                guint       prop_id,
                                GValue     *value,
                                GParamSpec *pspec)
{
  HdySwipeTracker *self = HDY_SWIPE_TRACKER (object);

  switch (prop_id) {
  case PROP_SWIPEABLE:
    g_value_set_object (value, hdy_swipe_tracker_get_swipeable (self));
    break;

  case PROP_ENABLED:
    g_value_set_boolean (value, hdy_swipe_tracker_get_enabled (self));
    break;

  case PROP_REVERSED:
    g_value_set_boolean (value, hdy_swipe_tracker_get_reversed (self));
    break;

  case PROP_ALLOW_MOUSE_DRAG:
    g_value_set_boolean (value, hdy_swipe_tracker_get_allow_mouse_drag (self));
    break;

  case PROP_ALLOW_LONG_SWIPES:
    g_value_set_boolean (value, hdy_swipe_tracker_get_allow_long_swipes (self));
    break;

  case PROP_ORIENTATION:
    g_value_set_enum (value, self->orientation);
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_swipe_tracker_set_property (GObject      *object,
                                guint         prop_id,
                                const GValue *value,
                                GParamSpec   *pspec)
{
  HdySwipeTracker *self = HDY_SWIPE_TRACKER (object);

  switch (prop_id) {
  case PROP_SWIPEABLE:
    self->swipeable = HDY_SWIPEABLE (g_object_ref (g_value_get_object (value)));
    break;

  case PROP_ENABLED:
    hdy_swipe_tracker_set_enabled (self, g_value_get_boolean (value));
    break;

  case PROP_REVERSED:
    hdy_swipe_tracker_set_reversed (self, g_value_get_boolean (value));
    break;

  case PROP_ALLOW_MOUSE_DRAG:
    hdy_swipe_tracker_set_allow_mouse_drag (self, g_value_get_boolean (value));
    break;

  case PROP_ALLOW_LONG_SWIPES:
    hdy_swipe_tracker_set_allow_long_swipes (self, g_value_get_boolean (value));
    break;

  case PROP_ORIENTATION:
    {
      GtkOrientation orientation = g_value_get_enum (value);
      if (orientation != self->orientation) {
        self->orientation = g_value_get_enum (value);
        g_object_notify (G_OBJECT (self), "orientation");
      }
    }
    break;

  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
  }
}

static void
hdy_swipe_tracker_class_init (HdySwipeTrackerClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);

  object_class->constructed = hdy_swipe_tracker_constructed;
  object_class->dispose = hdy_swipe_tracker_dispose;
  object_class->get_property = hdy_swipe_tracker_get_property;
  object_class->set_property = hdy_swipe_tracker_set_property;

  /**
   * HdySwipeTracker:swipeable:
   *
   * The widget the swipe tracker is attached to. Must not be %NULL.
   *
   * Since: 1.0
   */
  props[PROP_SWIPEABLE] =
    g_param_spec_object ("swipeable",
                         _("Swipeable"),
                         _("The swipeable the swipe tracker is attached to"),
                         HDY_TYPE_SWIPEABLE,
                         G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY);

  /**
   * HdySwipeTracker:enabled:
   *
   * Whether the swipe tracker is enabled. When it's not enabled, no events
   * will be processed. Usually widgets will want to expose this via a property.
   *
   * Since: 1.0
   */
  props[PROP_ENABLED] =
    g_param_spec_boolean ("enabled",
                          _("Enabled"),
                          _("Whether the swipe tracker processes events"),
                          TRUE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdySwipeTracker:reversed:
   *
   * Whether to reverse the swipe direction. If the swipe tracker is horizontal,
   * it can be used for supporting RTL text direction.
   *
   * Since: 1.0
   */
  props[PROP_REVERSED] =
    g_param_spec_boolean ("reversed",
                          _("Reversed"),
                          _("Whether swipe direction is reversed"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdySwipeTracker:allow-mouse-drag:
   *
   * Whether to allow dragging with mouse pointer. This should usually be
   * %FALSE.
   *
   * Since: 1.0
   */
  props[PROP_ALLOW_MOUSE_DRAG] =
    g_param_spec_boolean ("allow-mouse-drag",
                          _("Allow mouse drag"),
                          _("Whether to allow dragging with mouse pointer"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  /**
   * HdySwipeTracker:allow-long-swipes:
   *
   * Whether to allow swiping for more than one snap point at a time. If the
   * value is %FALSE, each swipe can only move to the adjacent snap points.
   *
   * Since: 1.2
   */
  props[PROP_ALLOW_LONG_SWIPES] =
    g_param_spec_boolean ("allow-long-swipes",
                          _("Allow long swipes"),
                          _("Whether to allow swiping for more than one snap point at a time"),
                          FALSE,
                          G_PARAM_READWRITE | G_PARAM_EXPLICIT_NOTIFY);

  g_object_class_override_property (object_class,
                                    PROP_ORIENTATION,
                                    "orientation");

  g_object_class_install_properties (object_class, LAST_PROP, props);

  /**
   * HdySwipeTracker::begin-swipe:
   * @self: The #HdySwipeTracker instance
   * @direction: The direction of the swipe
   * @direct: %TRUE if the swipe is directly triggered by a gesture,
   *   %FALSE if it's triggered via a #HdySwipeGroup
   *
   * This signal is emitted when a possible swipe is detected.
   *
   * The @direction value can be used to restrict the swipe to a certain
   * direction.
   *
   * Since: 1.0
   */
  signals[SIGNAL_BEGIN_SWIPE] =
    g_signal_new ("begin-swipe",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_FIRST,
                  0,
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  2,
                  HDY_TYPE_NAVIGATION_DIRECTION, G_TYPE_BOOLEAN);

  /**
   * HdySwipeTracker::update-swipe:
   * @self: The #HdySwipeTracker instance
   * @progress: The current animation progress value
   *
   * This signal is emitted every time the progress value changes.
   *
   * Since: 1.0
   */
  signals[SIGNAL_UPDATE_SWIPE] =
    g_signal_new ("update-swipe",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_FIRST,
                  0,
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  1,
                  G_TYPE_DOUBLE);

  /**
   * HdySwipeTracker::end-swipe:
   * @self: The #HdySwipeTracker instance
   * @duration: Snap-back animation duration in milliseconds
   * @to: The progress value to animate to
   *
   * This signal is emitted as soon as the gesture has stopped.
   *
   * Since: 1.0
   */
  signals[SIGNAL_END_SWIPE] =
    g_signal_new ("end-swipe",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_FIRST,
                  0,
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  2,
                  G_TYPE_INT64, G_TYPE_DOUBLE);
}

static void
hdy_swipe_tracker_init (HdySwipeTracker *self)
{
  self->event_history = g_array_new (FALSE, FALSE, sizeof (EventHistoryRecord));
  reset (self);

  self->orientation = GTK_ORIENTATION_HORIZONTAL;
  self->enabled = TRUE;
}

/**
 * hdy_swipe_tracker_new:
 * @swipeable: a #GtkWidget to add the tracker on
 *
 * Create a new #HdySwipeTracker object on @widget.
 *
 * Returns: the newly created #HdySwipeTracker object
 *
 * Since: 1.0
 */
HdySwipeTracker *
hdy_swipe_tracker_new (HdySwipeable *swipeable)
{
  g_return_val_if_fail (HDY_IS_SWIPEABLE (swipeable), NULL);

  return g_object_new (HDY_TYPE_SWIPE_TRACKER,
                       "swipeable", swipeable,
                       NULL);
}

/**
 * hdy_swipe_tracker_get_swipeable:
 * @self: a #HdySwipeTracker
 *
 * Get @self's swipeable widget.
 *
 * Returns: (transfer none): the swipeable widget
 *
 * Since: 1.0
 */
HdySwipeable *
hdy_swipe_tracker_get_swipeable (HdySwipeTracker *self)
{
  g_return_val_if_fail (HDY_IS_SWIPE_TRACKER (self), NULL);

  return self->swipeable;
}

/**
 * hdy_swipe_tracker_get_enabled:
 * @self: a #HdySwipeTracker
 *
 * Get whether @self is enabled. When it's not enabled, no events will be
 * processed. Generally widgets will want to expose this via a property.
 *
 * Returns: %TRUE if @self is enabled
 *
 * Since: 1.0
 */
gboolean
hdy_swipe_tracker_get_enabled (HdySwipeTracker *self)
{
  g_return_val_if_fail (HDY_IS_SWIPE_TRACKER (self), FALSE);

  return self->enabled;
}

/**
 * hdy_swipe_tracker_set_enabled:
 * @self: a #HdySwipeTracker
 * @enabled: whether to enable to swipe tracker
 *
 * Set whether @self is enabled. When it's not enabled, no events will be
 * processed. Usually widgets will want to expose this via a property.
 *
 * Since: 1.0
 */
void
hdy_swipe_tracker_set_enabled (HdySwipeTracker *self,
                               gboolean         enabled)
{
  g_return_if_fail (HDY_IS_SWIPE_TRACKER (self));

  enabled = !!enabled;

  if (self->enabled == enabled)
    return;

  self->enabled = enabled;

  if (!enabled && self->state != HDY_SWIPE_TRACKER_STATE_SCROLLING)
    reset (self);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_ENABLED]);
}

/**
 * hdy_swipe_tracker_get_reversed:
 * @self: a #HdySwipeTracker
 *
 * Get whether @self is reversing the swipe direction.
 *
 * Returns: %TRUE is the direction is reversed
 *
 * Since: 1.0
 */
gboolean
hdy_swipe_tracker_get_reversed (HdySwipeTracker *self)
{
  g_return_val_if_fail (HDY_IS_SWIPE_TRACKER (self), FALSE);

  return self->reversed;
}

/**
 * hdy_swipe_tracker_set_reversed:
 * @self: a #HdySwipeTracker
 * @reversed: whether to reverse the swipe direction
 *
 * Set whether to reverse the swipe direction. If @self is horizontal,
 * can be used for supporting RTL text direction.
 *
 * Since: 1.0
 */
void
hdy_swipe_tracker_set_reversed (HdySwipeTracker *self,
                                gboolean         reversed)
{
  g_return_if_fail (HDY_IS_SWIPE_TRACKER (self));

  reversed = !!reversed;

  if (self->reversed == reversed)
    return;

  self->reversed = reversed;
  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_REVERSED]);
}

/**
 * hdy_swipe_tracker_get_allow_mouse_drag:
 * @self: a #HdySwipeTracker
 *
 * Get whether @self can be dragged with mouse pointer.
 *
 * Returns: %TRUE is mouse dragging is allowed
 *
 * Since: 1.0
 */
gboolean
hdy_swipe_tracker_get_allow_mouse_drag (HdySwipeTracker *self)
{
  g_return_val_if_fail (HDY_IS_SWIPE_TRACKER (self), FALSE);

  return self->allow_mouse_drag;
}

/**
 * hdy_swipe_tracker_set_allow_mouse_drag:
 * @self: a #HdySwipeTracker
 * @allow_mouse_drag: whether to allow mouse dragging
 *
 * Set whether @self can be dragged with mouse pointer. This should usually be
 * %FALSE.
 *
 * Since: 1.0
 */
void
hdy_swipe_tracker_set_allow_mouse_drag (HdySwipeTracker *self,
                                        gboolean         allow_mouse_drag)
{
  g_return_if_fail (HDY_IS_SWIPE_TRACKER (self));

  allow_mouse_drag = !!allow_mouse_drag;

  if (self->allow_mouse_drag == allow_mouse_drag)
    return;

  self->allow_mouse_drag = allow_mouse_drag;

  if (self->touch_gesture)
    g_object_set (self->touch_gesture, "touch-only", !allow_mouse_drag, NULL);

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_ALLOW_MOUSE_DRAG]);
}

/**
 * hdy_swipe_tracker_get_allow_long_swipes:
 * @self: a #HdySwipeTracker
 *
 * Whether to allow swiping for more than one snap point at a time. If the
 * value is %FALSE, each swipe can only move to the adjacent snap points.
 *
 * Returns: %TRUE if long swipes are allowed, %FALSE otherwise
 *
 * Since: 1.2
 */
gboolean
hdy_swipe_tracker_get_allow_long_swipes (HdySwipeTracker *self)
{
  g_return_val_if_fail (HDY_IS_SWIPE_TRACKER (self), FALSE);

  return self->allow_long_swipes;
}

/**
 * hdy_swipe_tracker_set_allow_long_swipes:
 * @self: a #HdySwipeTracker
 * @allow_long_swipes: whether to allow long swipes
 *
 * Sets whether to allow swiping for more than one snap point at a time. If the
 * value is %FALSE, each swipe can only move to the adjacent snap points.
 *
 * Since: 1.2
 */
void
hdy_swipe_tracker_set_allow_long_swipes (HdySwipeTracker *self,
                                         gboolean         allow_long_swipes)
{
  g_return_if_fail (HDY_IS_SWIPE_TRACKER (self));

  allow_long_swipes = !!allow_long_swipes;

  if (self->allow_long_swipes == allow_long_swipes)
    return;

  self->allow_long_swipes = allow_long_swipes;

  g_object_notify_by_pspec (G_OBJECT (self), props[PROP_ALLOW_LONG_SWIPES]);
}

/**
 * hdy_swipe_tracker_shift_position:
 * @self: a #HdySwipeTracker
 * @delta: the position delta
 *
 * Move the current progress value by @delta. This can be used to adjust the
 * current position if snap points move during the gesture.
 *
 * Since: 1.0
 */
void
hdy_swipe_tracker_shift_position (HdySwipeTracker *self,
                                  gdouble          delta)
{
  g_return_if_fail (HDY_IS_SWIPE_TRACKER (self));

  if (self->state != HDY_SWIPE_TRACKER_STATE_PENDING &&
      self->state != HDY_SWIPE_TRACKER_STATE_SCROLLING)
    return;

  self->progress += delta;
  self->initial_progress += delta;
}

void
hdy_swipe_tracker_emit_begin_swipe (HdySwipeTracker        *self,
                                    HdyNavigationDirection  direction,
                                    gboolean                direct)
{
  g_return_if_fail (HDY_IS_SWIPE_TRACKER (self));

  g_signal_emit (self, signals[SIGNAL_BEGIN_SWIPE], 0, direction, direct);
}

void
hdy_swipe_tracker_emit_update_swipe (HdySwipeTracker *self,
                                     gdouble          progress)
{
  g_return_if_fail (HDY_IS_SWIPE_TRACKER (self));

  g_signal_emit (self, signals[SIGNAL_UPDATE_SWIPE], 0, progress);
}

void
hdy_swipe_tracker_emit_end_swipe (HdySwipeTracker *self,
                                  gint64           duration,
                                  gdouble          to)
{
  g_return_if_fail (HDY_IS_SWIPE_TRACKER (self));

  g_signal_emit (self, signals[SIGNAL_END_SWIPE], 0, duration, to);
}
