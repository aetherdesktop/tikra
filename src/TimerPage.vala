using Gtk;
using Adw;

namespace Tikra {
    public class TimerPage : Box {
        private Label time_label;
        private SpinButton hours_spin;
        private SpinButton minutes_spin;
        private SpinButton seconds_spin;
        private Button start_stop_button;
        private Button reset_button;
        
        private int64 target_time;
        private int64 remaining_time;
        private bool is_running;
        private uint timeout_id;

        public TimerPage () {
            Object (orientation: Orientation.VERTICAL, spacing: 24);
            setup_ui ();
        }

        private void setup_ui () {
            halign = Align.FILL;
            valign = Align.FILL;
            hexpand = true;
            vexpand = true;
            spacing = 24;

            // Main container
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
            
            // Input controls card
            var controls_card = new Adw.Bin ();
            controls_card.add_css_class ("card");
            
            var controls_container = new Box (Orientation.VERTICAL, 20);
            controls_container.margin_top = 24;
            controls_container.margin_bottom = 24;
            controls_container.margin_start = 24;
            controls_container.margin_end = 24;

            var input_title = new Label ("Set Timer");
            input_title.add_css_class ("heading");
            input_title.halign = Align.CENTER;
            
            var input_box = new Box (Orientation.HORIZONTAL, 16);
            input_box.halign = Align.CENTER;
            
            var hours_box = new Box (Orientation.VERTICAL, 8);
            hours_box.halign = Align.CENTER;
            var hours_label = new Label ("Hours");
            hours_label.add_css_class ("caption-heading");
            hours_spin = new SpinButton.with_range (0, 23, 1);
            hours_spin.value = 0;
            hours_spin.width_chars = 3;
            hours_box.append (hours_label);
            hours_box.append (hours_spin);
            
            var minutes_box = new Box (Orientation.VERTICAL, 8);
            minutes_box.halign = Align.CENTER;
            var minutes_label = new Label ("Minutes");
            minutes_label.add_css_class ("caption-heading");
            minutes_spin = new SpinButton.with_range (0, 59, 1);
            minutes_spin.value = 5;
            minutes_spin.width_chars = 3;
            minutes_box.append (minutes_label);
            minutes_box.append (minutes_spin);
            
            var seconds_box = new Box (Orientation.VERTICAL, 8);
            seconds_box.halign = Align.CENTER;
            var seconds_label = new Label ("Seconds");
            seconds_label.add_css_class ("caption-heading");
            seconds_spin = new SpinButton.with_range (0, 59, 1);
            seconds_spin.value = 0;
            seconds_spin.width_chars = 3;
            seconds_box.append (seconds_label);
            seconds_box.append (seconds_spin);
            
            input_box.append (hours_box);
            input_box.append (minutes_box);
            input_box.append (seconds_box);

            controls_container.append (input_title);
            controls_container.append (input_box);
            controls_card.child = controls_container;
            
            // Control buttons
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
            
            buttons_box.append (reset_button);
            buttons_box.append (start_stop_button);

            main_box.append (time_card);
            main_box.append (controls_card);
            main_box.append (buttons_box);
            
            main_clamp.child = main_box;
            append (main_clamp);
            
            // Connect spin button changes to update display
            hours_spin.value_changed.connect (update_display);
            minutes_spin.value_changed.connect (update_display);
            seconds_spin.value_changed.connect (update_display);
            
            is_running = false;
            update_display ();
        }

        private void on_start_stop_clicked () {
            if (is_running) {
                stop_timer ();
            } else {
                start_timer ();
            }
        }

        private void start_timer () {
            if (!is_running) {
                var total_seconds = (int64)(hours_spin.value * 3600 + minutes_spin.value * 60 + seconds_spin.value);
                if (total_seconds == 0 && remaining_time == 0) return;
                
                if (remaining_time == 0) {
                    remaining_time = total_seconds * 1000000; // Convert to microseconds
                }
                target_time = get_monotonic_time () + remaining_time;
            }
            
            is_running = true;
            start_stop_button.label = "Pause";
            start_stop_button.remove_css_class ("suggested-action");
            start_stop_button.add_css_class ("destructive-action");
            reset_button.sensitive = false;
            
            // Disable spin buttons
            hours_spin.sensitive = false;
            minutes_spin.sensitive = false;
            seconds_spin.sensitive = false;
            
            timeout_id = Timeout.add (100, update_timer);
        }

        private void stop_timer () {
            is_running = false;
            start_stop_button.label = "Start";
            start_stop_button.remove_css_class ("destructive-action");
            start_stop_button.add_css_class ("suggested-action");
            reset_button.sensitive = true;
            
            if (timeout_id != 0) {
                Source.remove (timeout_id);
                timeout_id = 0;
            }
        }

        private void on_reset_clicked () {
            remaining_time = 0;
            reset_button.sensitive = false;
            
            // Enable spin buttons
            hours_spin.sensitive = true;
            minutes_spin.sensitive = true;
            seconds_spin.sensitive = true;
            
            update_display ();
        }

        private bool update_timer () {
            remaining_time = target_time - get_monotonic_time ();
            
            if (remaining_time <= 0) {
                remaining_time = 0;
                is_running = false;
                start_stop_button.label = "Start";
                start_stop_button.remove_css_class ("destructive-action");
                start_stop_button.add_css_class ("suggested-action");
                reset_button.sensitive = true;
                
                // Enable spin buttons
                hours_spin.sensitive = true;
                minutes_spin.sensitive = true;
                seconds_spin.sensitive = true;
                
                // Show timer finished notification
                time_label.add_css_class ("error");
                Timeout.add_seconds (3, () => {
                    time_label.remove_css_class ("error");
                    return Source.REMOVE;
                });
                
                update_display ();
                return Source.REMOVE;
            }
            
            update_display ();
            return Source.CONTINUE;
        }

        private void update_display () {
            int64 display_time;
            
            if (is_running || remaining_time > 0) {
                display_time = remaining_time;
            } else {
                var total_seconds = (int64)(hours_spin.value * 3600 + minutes_spin.value * 60 + seconds_spin.value);
                display_time = total_seconds * 1000000;
            }
            
            time_label.label = format_time (display_time);
        }

        private string format_time (int64 microseconds) {
            var total_seconds = microseconds / 1000000;
            var hours = (long)(total_seconds / 3600);
            var minutes = (long)((total_seconds % 3600) / 60);
            var seconds = (long)(total_seconds % 60);
            
            return "%02ld:%02ld:%02ld".printf (hours, minutes, seconds);
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