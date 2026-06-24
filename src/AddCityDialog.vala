using Gtk;
using Adw;

namespace Tikra {
    public class AddCityDialog : Adw.Dialog {
        public signal void city_selected (string name, string tz_id);

        private ListBox results_list;
        private SearchEntry search_entry;
        private string[] already_added;

        private struct CityEntry {
            string name;
            string tz_id;
        }

        private static CityEntry[] all_cities = {
            {"Abidjan", "Africa/Abidjan"},
            {"Accra", "Africa/Accra"},
            {"Addis Ababa", "Africa/Addis_Ababa"},
            {"Algiers", "Africa/Algiers"},
            {"Cairo", "Africa/Cairo"},
            {"Casablanca", "Africa/Casablanca"},
            {"Johannesburg", "Africa/Johannesburg"},
            {"Lagos", "Africa/Lagos"},
            {"Nairobi", "Africa/Nairobi"},
            {"Tunis", "Africa/Tunis"},
            {"Buenos Aires", "America/Argentina/Buenos_Aires"},
            {"La Paz", "America/La_Paz"},
            {"Bogota", "America/Bogota"},
            {"Chicago", "America/Chicago"},
            {"Denver", "America/Denver"},
            {"Caracas", "America/Caracas"},
            {"Guayaquil", "America/Guayaquil"},
            {"Havana", "America/Havana"},
            {"Lima", "America/Lima"},
            {"Los Angeles", "America/Los_Angeles"},
            {"Mexico City", "America/Mexico_City"},
            {"New York", "America/New_York"},
            {"Panama", "America/Panama"},
            {"Phoenix", "America/Phoenix"},
            {"Santiago", "America/Santiago"},
            {"Sao Paulo", "America/Sao_Paulo"},
            {"Toronto", "America/Toronto"},
            {"Vancouver", "America/Vancouver"},
            {"Almaty", "Asia/Almaty"},
            {"Amman", "Asia/Amman"},
            {"Baghdad", "Asia/Baghdad"},
            {"Baku", "Asia/Baku"},
            {"Bangkok", "Asia/Bangkok"},
            {"Beirut", "Asia/Beirut"},
            {"Colombo", "Asia/Colombo"},
            {"Dhaka", "Asia/Dhaka"},
            {"Dubai", "Asia/Dubai"},
            {"Ho Chi Minh City", "Asia/Ho_Chi_Minh"},
            {"Hong Kong", "Asia/Hong_Kong"},
            {"Jakarta", "Asia/Jakarta"},
            {"Jerusalem", "Asia/Jerusalem"},
            {"Kabul", "Asia/Kabul"},
            {"Karachi", "Asia/Karachi"},
            {"Kathmandu", "Asia/Kathmandu"},
            {"Kolkata", "Asia/Kolkata"},
            {"Kuala Lumpur", "Asia/Kuala_Lumpur"},
            {"Kuwait", "Asia/Kuwait"},
            {"Manila", "Asia/Manila"},
            {"Muscat", "Asia/Muscat"},
            {"Nicosia", "Asia/Nicosia"},
            {"Novosibirsk", "Asia/Novosibirsk"},
            {"Phnom Penh", "Asia/Phnom_Penh"},
            {"Riyadh", "Asia/Riyadh"},
            {"Seoul", "Asia/Seoul"},
            {"Shanghai", "Asia/Shanghai"},
            {"Singapore", "Asia/Singapore"},
            {"Taipei", "Asia/Taipei"},
            {"Tashkent", "Asia/Tashkent"},
            {"Tbilisi", "Asia/Tbilisi"},
            {"Tehran", "Asia/Tehran"},
            {"Tokyo", "Asia/Tokyo"},
            {"Ulaanbaatar", "Asia/Ulaanbaatar"},
            {"Vladivostok", "Asia/Vladivostok"},
            {"Yekaterinburg", "Asia/Yekaterinburg"},
            {"Yerevan", "Asia/Yerevan"},
            {"Adelaide", "Australia/Adelaide"},
            {"Brisbane", "Australia/Brisbane"},
            {"Darwin", "Australia/Darwin"},
            {"Melbourne", "Australia/Melbourne"},
            {"Perth", "Australia/Perth"},
            {"Sydney", "Australia/Sydney"},
            {"Amsterdam", "Europe/Amsterdam"},
            {"Athens", "Europe/Athens"},
            {"Belgrade", "Europe/Belgrade"},
            {"Berlin", "Europe/Berlin"},
            {"Brussels", "Europe/Brussels"},
            {"Bucharest", "Europe/Bucharest"},
            {"Budapest", "Europe/Budapest"},
            {"Copenhagen", "Europe/Copenhagen"},
            {"Dublin", "Europe/Dublin"},
            {"Helsinki", "Europe/Helsinki"},
            {"Istanbul", "Europe/Istanbul"},
            {"Kiev", "Europe/Kiev"},
            {"Lisbon", "Europe/Lisbon"},
            {"London", "Europe/London"},
            {"Luxembourg", "Europe/Luxembourg"},
            {"Madrid", "Europe/Madrid"},
            {"Minsk", "Europe/Minsk"},
            {"Moscow", "Europe/Moscow"},
            {"Oslo", "Europe/Oslo"},
            {"Paris", "Europe/Paris"},
            {"Prague", "Europe/Prague"},
            {"Riga", "Europe/Riga"},
            {"Rome", "Europe/Rome"},
            {"Samara", "Europe/Samara"},
            {"Sofia", "Europe/Sofia"},
            {"Stockholm", "Europe/Stockholm"},
            {"Tallinn", "Europe/Tallinn"},
            {"Vienna", "Europe/Vienna"},
            {"Vilnius", "Europe/Vilnius"},
            {"Warsaw", "Europe/Warsaw"},
            {"Zurich", "Europe/Zurich"},
            {"Auckland", "Pacific/Auckland"},
            {"Fiji", "Pacific/Fiji"},
            {"Honolulu", "Pacific/Honolulu"},
        };

        public AddCityDialog (string[] added_tz_ids) {
            Object (title: "Add City", content_width: 380, content_height: 480);
            already_added = added_tz_ids;
            setup_ui ();
        }

        private void setup_ui () {
            var toolbar_view = new Adw.ToolbarView ();

            var header = new Adw.HeaderBar ();
            toolbar_view.add_top_bar (header);

            var content_box = new Box (Orientation.VERTICAL, 0);

            search_entry = new SearchEntry ();
            search_entry.placeholder_text = "Search cities...";
            search_entry.margin_top = 8;
            search_entry.margin_bottom = 8;
            search_entry.margin_start = 12;
            search_entry.margin_end = 12;
            search_entry.search_changed.connect (() => results_list.invalidate_filter ());

            var scrolled = new ScrolledWindow ();
            scrolled.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            scrolled.vexpand = true;

            results_list = new ListBox ();
            results_list.add_css_class ("boxed-list-separate");
            results_list.set_filter_func (filter_row);
            results_list.row_activated.connect (on_row_activated);
            scrolled.child = results_list;

            foreach (var city in all_cities) {
                if (is_already_added (city.tz_id)) continue;

                var row = new ActionRow ();
                row.title = city.name;
                row.subtitle = city.tz_id;
                row.activatable = true;
                row.set_data ("tz_id", city.tz_id);
                results_list.append (row);
            }

            content_box.append (search_entry);
            content_box.append (scrolled);
            toolbar_view.content = content_box;

            set_child (toolbar_view);
        }

        private bool filter_row (ListBoxRow row) {
            var text = search_entry.text.strip ().down ();
            if (text.length == 0) return true;

            var action_row = row as ActionRow;
            if (action_row == null) return false;

            return action_row.title.down ().contains (text)
                || action_row.subtitle.down ().contains (text);
        }

        private void on_row_activated (ListBoxRow row) {
            var action_row = row as ActionRow;
            if (action_row == null) return;

            var tz_id = action_row.get_data<string> ("tz_id");
            city_selected (action_row.title, tz_id);
            close ();
        }

        private bool is_already_added (string tz_id) {
            foreach (var id in already_added) {
                if (id == tz_id) return true;
            }
            return false;
        }
    }
}
