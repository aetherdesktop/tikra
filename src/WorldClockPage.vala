using Gtk;
using Adw;

namespace Tikra {
    public class WorldClockPage : Box {
        private ListBox clocks_list;
        private uint timeout_id;
        private GLib.Settings settings;

        public WorldClockPage () {
            Object (orientation: Orientation.VERTICAL, spacing: 12);
            settings = new GLib.Settings ("org.aether.tikra");
            setup_ui ();
            load_from_settings ();
            start_clocks ();
        }

        private void setup_ui () {
            halign = Align.FILL;
            valign = Align.FILL;
            hexpand = true;
            vexpand = true;
            spacing = 24;

            var main_clamp = new Adw.Clamp ();
            main_clamp.maximum_size = 700;
            main_clamp.margin_top = 32;
            main_clamp.margin_bottom = 32;
            main_clamp.margin_start = 24;
            main_clamp.margin_end = 24;

            var main_box = new Box (Orientation.VERTICAL, 24);

            var header_box = new Box (Orientation.HORIZONTAL, 0);
            header_box.hexpand = true;

            var title = new Label ("World Clock");
            title.add_css_class ("title-1");
            title.halign = Align.START;
            title.hexpand = true;
            title.margin_bottom = 16;

            var add_button = new Button ();
            add_button.icon_name = "list-add-symbolic";
            add_button.add_css_class ("flat");
            add_button.tooltip_text = "Add city";
            add_button.valign = Align.CENTER;
            add_button.clicked.connect (on_add_clicked);

            header_box.append (title);
            header_box.append (add_button);

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

            main_box.append (header_box);
            main_box.append (clocks_card);

            main_clamp.child = main_box;
            append (main_clamp);
        }

        private void load_from_settings () {
            var cities = settings.get_strv ("world-clock-cities");
            foreach (var entry in cities) {
                var parts = entry.split ("|", 2);
                if (parts.length == 2) {
                    append_city_row (parts[0], parts[1]);
                }
            }
        }

        private void save_to_settings () {
            string[] entries = {};
            var child = clocks_list.get_first_child ();
            while (child != null) {
                var row = child as ActionRow;
                if (row != null) {
                    var tz_id = row.get_data<string> ("tz_id");
                    entries += row.title + "|" + tz_id;
                }
                child = child.get_next_sibling ();
            }
            settings.set_strv ("world-clock-cities", entries);
        }

        private void append_city_row (string name, string tz_id) {
            var row = new ActionRow ();
            row.title = name;

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

            var remove_button = new Button ();
            remove_button.icon_name = "list-remove-symbolic";
            remove_button.add_css_class ("flat");
            remove_button.add_css_class ("circular");
            remove_button.tooltip_text = "Remove";
            remove_button.valign = Align.CENTER;
            remove_button.clicked.connect (() => {
                clocks_list.remove (row);
                save_to_settings ();
            });

            row.add_suffix (time_box);
            row.add_suffix (remove_button);
            row.set_data ("tz_id", tz_id);
            row.set_data ("time_label", time_label);
            row.set_data ("date_label", date_label);

            clocks_list.append (row);
            update_timezone_display (tz_id, time_label, date_label);
        }

        private void on_add_clicked () {
            string[] current_ids = {};
            var child = clocks_list.get_first_child ();
            while (child != null) {
                var row = child as ActionRow;
                if (row != null) {
                    current_ids += row.get_data<string> ("tz_id");
                }
                child = child.get_next_sibling ();
            }

            var dialog = new AddCityDialog (current_ids);
            dialog.city_selected.connect ((name, tz_id) => {
                append_city_row (name, tz_id);
                save_to_settings ();
            });
            dialog.present (get_root () as Gtk.Window);
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
                var row = child as ActionRow;
                if (row != null) {
                    var tz_id = row.get_data<string> ("tz_id");
                    var time_label = row.get_data<Label> ("time_label");
                    var date_label = row.get_data<Label> ("date_label");
                    if (tz_id != null && time_label != null && date_label != null) {
                        update_timezone_display (tz_id, time_label, date_label);
                    }
                }
                child = child.get_next_sibling ();
            }
        }

        private void update_timezone_display (string tz_id, Label time_label, Label date_label) {
            try {
                var tz = new TimeZone.identifier (tz_id);
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
