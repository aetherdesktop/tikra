using Gtk;
using Adw;

namespace Tikra {
    public class WorldClockPage : Box {
        private ListBox clocks_list;
        private uint timeout_id;
        
        private struct TimeZoneInfo {
            string name;
            string tz_id;
        }

        private TimeZoneInfo[] timezones = {
            {"New York", "America/New_York"},
            {"London", "Europe/London"},
            {"Paris", "Europe/Paris"},
            {"Moscow", "Europe/Moscow"},
            {"Dubai", "Asia/Dubai"},
            {"Delhi", "Asia/Kolkata"},
            {"Shanghai", "Asia/Shanghai"},
            {"Tokyo", "Asia/Tokyo"},
            {"Sydney", "Australia/Sydney"},
            {"Los Angeles", "America/Los_Angeles"}
        };

        public WorldClockPage () {
            Object (orientation: Orientation.VERTICAL, spacing: 12);
            setup_ui ();
            start_clocks ();
        }

        private void setup_ui () {
            halign = Align.FILL;
            valign = Align.FILL;
            hexpand = true;
            vexpand = true;
            spacing = 24;

            // Main container
            var main_clamp = new Adw.Clamp ();
            main_clamp.maximum_size = 700;
            main_clamp.margin_top = 32;
            main_clamp.margin_bottom = 32;
            main_clamp.margin_start = 24;
            main_clamp.margin_end = 24;

            var main_box = new Box (Orientation.VERTICAL, 24);

            var title = new Label ("World Clock");
            title.add_css_class ("title-1");
            title.halign = Align.CENTER;
            title.margin_bottom = 16;

            // Clock list in a card
            var clocks_card = new Adw.Bin ();
            clocks_card.add_css_class ("card");
            clocks_card.vexpand = true;
            
            var scrolled = new ScrolledWindow ();
            scrolled.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            scrolled.vexpand = true;
            scrolled.margin_top = 8;
            scrolled.margin_bottom = 8;
            scrolled.margin_start = 8;
            scrolled.margin_end = 8;
            
            clocks_list = new ListBox ();
            clocks_list.add_css_class ("boxed-list");
            clocks_list.add_css_class ("background");
            scrolled.child = clocks_list;
            clocks_card.child = scrolled;

            main_box.append (title);
            main_box.append (clocks_card);
            
            main_clamp.child = main_box;
            append (main_clamp);
            
            setup_timezone_rows ();
        }

        private void setup_timezone_rows () {
            foreach (var tz in timezones) {
                var row = new ActionRow ();
                row.title = tz.name;
                
                var time_label = new Label ("");
                time_label.add_css_class ("numeric");
                time_label.add_css_class ("title-3");
                
                var date_label = new Label ("");
                date_label.add_css_class ("caption");
                
                var time_box = new Box (Orientation.VERTICAL, 0);
                time_box.halign = Align.END;
                time_box.valign = Align.CENTER;
                time_box.append (time_label);
                time_box.append (date_label);
                
                row.add_suffix (time_box);
                row.set_data ("timezone", tz.tz_id);
                row.set_data ("time_label", time_label);
                row.set_data ("date_label", date_label);
                
                clocks_list.append (row);
            }
        }

        private void start_clocks () {
            update_all_times ();
            timeout_id = Timeout.add_seconds (1, () => {
                update_all_times ();
                return Source.CONTINUE;
            });
        }

        private void update_all_times () {
            var child = clocks_list.get_first_child ();
            
            while (child != null) {
                if (child is ActionRow) {
                    var row = child as ActionRow;
                    var timezone = row.get_data<string> ("timezone");
                    var time_label = row.get_data<Label> ("time_label");
                    var date_label = row.get_data<Label> ("date_label");
                    
                    if (timezone != null && time_label != null && date_label != null) {
                        update_timezone_display (timezone, time_label, date_label);
                    }
                }
                child = child.get_next_sibling ();
            }
        }

        private void update_timezone_display (string timezone, Label time_label, Label date_label) {
            try {
                var tz = new TimeZone.identifier (timezone);
                var now = new DateTime.now (tz);
                time_label.label = now.format ("%H:%M:%S");
                date_label.label = now.format ("%b %d");
            } catch (Error e) {
                time_label.label = "--:--:--";
                date_label.label = "?";
            }
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