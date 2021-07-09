namespace Pebbles {
    public class ResponsiveBox : Gtk.Box {
        int total_width_request;
        public bool wrapping = false;
        public ResponsiveBox (int spacing) {
            this.hexpand = true;
            this.spacing = spacing;
            this.set_orientation (Gtk.Orientation.VERTICAL);

            this.draw.connect (() => {
                total_width_request = 0;
                foreach (Gtk.Widget widget in this.get_children ()) {
                    total_width_request += (widget.width_request + widget.margin_start + widget.margin_end);
                }
                if (total_width_request + 20 < this.get_allocated_width () && this.visible) {
                    this.set_orientation (Gtk.Orientation.HORIZONTAL);
                    wrapping = false;
                } else {
                    this.set_orientation (Gtk.Orientation.VERTICAL);
                    wrapping = true;
                }
                return false;
            });
            this.unmap.connect (() => {
                this.set_orientation (Gtk.Orientation.VERTICAL);
                wrapping = true;
            });
        }
    }
}