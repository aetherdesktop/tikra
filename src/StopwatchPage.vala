using Gtk;
using Adw;

namespace Tikra {
    public class StopwatchPage : Box {
        private Label time_label;
        private Button start_stop_button;
        private Button reset_button;
        private Button lap_button;
        private ListBox laps_list;
        
        private int64 start_time;
        private int64 elapsed_time;
        private bool is_running;
        private uint timeout_id;
        private int lap_count;

        public StopwatchPage () {
            Object (orientation: Orientation.VERTICAL, spacing: 24);
            setup_ui ();
        }

        private void setup_ui () {
            halign = Align.FILL;
            valign = Align.FILL;
            hexpand = true;
            vexpand = true;
            spacing = 24;

            // Main container with clamp
            var main_clamp = new Adw.Clamp ();
            main_clamp.maximum_size = 600;
            main_clamp.margin_top = 32;
            main_clamp.margin_bottom = 32;
            main_clamp.margin_start = 24;
            main_clamp.margin_end = 24;

            var main_box = new Box (Orientation.VERTICAL, 32);
            main_box.halign = Align.CENTER;

            // Time display card
            var time_card = new Adw.Bin ();
            time_card.add_css_class ("card");
            time_card.add_css_class ("time-display");
            
            var time_container = new Box (Orientation.VERTICAL, 16);
            time_container.margin_top = 48;
            time_container.margin_bottom = 48;
            time_container.margin_start = 32;
            time_container.margin_end = 32;
            time_container.halign = Align.CENTER;

            time_label = new Label ("00:00:00");
            time_label.add_css_class ("title-1");
            time_label.add_css_class ("numeric");
            time_label.add_css_class ("monospace");
            
            time_container.append (time_label);
            time_card.child = time_container;

            // Control buttons with better styling
            var buttons_box = new Box (Orientation.HORIZONTAL, 16);
            buttons_box.halign = Align.CENTER;
            buttons_box.margin_top = 16;
            
            start_stop_button = new Button.with_label ("Start");
            start_stop_button.add_css_class ("suggested-action");
            start_stop_button.add_css_class ("pill");
            start_stop_button.clicked.connect (on_start_stop_clicked);
            
            reset_button = new Button.with_label ("Reset");
            reset_button.add_css_class ("pill");
            reset_button.sensitive = false;
            reset_button.clicked.connect (on_reset_clicked);
            
            lap_button = new Button.with_label ("Lap");
            lap_button.add_css_class ("pill");
            lap_button.sensitive = false;
            lap_button.clicked.connect (on_lap_clicked);
            
            buttons_box.append (reset_button);
            buttons_box.append (start_stop_button);
            buttons_box.append (lap_button);

            // Laps section with card styling
            var laps_card = new Adw.Bin ();
            laps_card.add_css_class ("card");
            laps_card.vexpand = true;
            
            var laps_container = new Box (Orientation.VERTICAL, 12);
            laps_container.margin_top = 16;
            laps_container.margin_bottom = 16;
            laps_container.margin_start = 16;
            laps_container.margin_end = 16;

            var laps_title = new Label ("Laps");
            laps_title.add_css_class ("heading");
            laps_title.halign = Align.START;
            
            var scrolled = new ScrolledWindow ();
            scrolled.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            scrolled.vexpand = true;
            
            laps_list = new ListBox ();
            laps_list.add_css_class ("boxed-list");
            scrolled.child = laps_list;

            laps_container.append (laps_title);
            laps_container.append (scrolled);
            laps_card.child = laps_container;

            main_box.append (time_card);
            main_box.append (buttons_box);
            main_box.append (laps_card);
            
            main_clamp.child = main_box;
            append (main_clamp);
            
            start_time = 0;
            elapsed_time = 0;
            is_running = false;
            lap_count = 0;
        }

        private void on_start_stop_clicked () {
            if (is_running) {
                stop_stopwatch ();
            } else {
                start_stopwatch ();
            }
        }

        private void start_stopwatch () {
            start_time = get_monotonic_time () - elapsed_time;
            is_running = true;
            start_stop_button.label = "Stop";
            start_stop_button.remove_css_class ("suggested-action");
            start_stop_button.add_css_class ("destructive-action");
            reset_button.sensitive = false;
            lap_button.sensitive = true;
            
            timeout_id = Timeout.add (10, update_display);
        }

        private void stop_stopwatch () {
            is_running = false;
            start_stop_button.label = "Start";
            start_stop_button.remove_css_class ("destructive-action");
            start_stop_button.add_css_class ("suggested-action");
            reset_button.sensitive = true;
            lap_button.sensitive = false;
            
            if (timeout_id != 0) {
                Source.remove (timeout_id);
                timeout_id = 0;
            }
        }

        private void on_reset_clicked () {
            elapsed_time = 0;
            update_display ();
            reset_button.sensitive = false;
            lap_count = 0;
            
            // Clear laps
            var child = laps_list.get_first_child ();
            while (child != null) {
                var next = child.get_next_sibling ();
                laps_list.remove (child);
                child = next;
            }
        }

        private void on_lap_clicked () {
            if (!is_running) return;
            
            lap_count++;
            var lap_time = get_monotonic_time () - start_time;
            var formatted_time = format_time (lap_time);
            
            var row = new ActionRow ();
            row.title = @"Lap $lap_count";
            row.subtitle = formatted_time;
            
            laps_list.prepend (row);
        }

        private bool update_display () {
            if (is_running) {
                elapsed_time = get_monotonic_time () - start_time;
            }
            
            time_label.label = format_time (elapsed_time);
            return is_running;
        }

        private string format_time (int64 microseconds) {
            var total_seconds = microseconds / 1000000;
            var minutes = (long)(total_seconds / 60);
            var seconds = (long)(total_seconds % 60);
            var centiseconds = (long)((microseconds % 1000000) / 10000);
            
            return "%02ld:%02ld:%02ld".printf (minutes, seconds, centiseconds);
        }

        public override void dispose () {
            if (timeout_id != 0) {
                Source.remove (timeout_id);
                timeout_id = 0;
            }
            base.dispose ();
        }
    }
}