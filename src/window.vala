using Gtk;
using Adw;

namespace Tikra {
    public class MainWindow : Adw.ApplicationWindow {
        private Adw.ViewStack view_stack;
        private Adw.ViewSwitcher view_switcher;
        private Adw.ViewSwitcherBar view_switcher_bar;

        public MainWindow (Gtk.Application app) {
            Object (application: app);
            setup_ui ();
        }

        private void setup_ui () {
            set_default_size (900, 700);
            title = "Tikra";
            
            // Create view stack
            view_stack = new Adw.ViewStack ();
            
            // Create view switcher for header
            view_switcher = new Adw.ViewSwitcher ();
            view_switcher.stack = view_stack;
            view_switcher.policy = Adw.ViewSwitcherPolicy.WIDE;
            
            // Create view switcher bar for narrow mode
            view_switcher_bar = new Adw.ViewSwitcherBar ();
            view_switcher_bar.stack = view_stack;
            
            var header_bar = new Adw.HeaderBar ();
            header_bar.title_widget = view_switcher;
            
            var menu_button = new MenuButton ();
            menu_button.icon_name = "open-menu-symbolic";
            menu_button.tooltip_text = "Main Menu";
            
            var menu_model = new Menu ();
            menu_model.append ("About Tikra", "app.about");
            menu_model.append ("Quit", "app.quit");
            
            menu_button.menu_model = menu_model;
            header_bar.pack_end (menu_button);
            
            // Add pages to view stack
            var clock_page = new ClockPage ();
            view_stack.add_titled (clock_page, "clock", "Clock");
            view_stack.set_visible_child_name ("clock");
            
            var stopwatch_page = new StopwatchPage ();
            view_stack.add_titled (stopwatch_page, "stopwatch", "Stopwatch");
            
            var timer_page = new TimerPage ();
            view_stack.add_titled (timer_page, "timer", "Timer");
            
            var world_clock_page = new WorldClockPage ();
            view_stack.add_titled (world_clock_page, "world-clock", "World Clock");
            
            // Set icons for view switcher buttons
            view_stack.get_page (clock_page).icon_name = "preferences-system-time-symbolic";
            view_stack.get_page (stopwatch_page).icon_name = "media-playback-start-symbolic";
            view_stack.get_page (timer_page).icon_name = "alarm-symbolic";
            view_stack.get_page (world_clock_page).icon_name = "mark-location-symbolic";
            
            view_switcher_bar.reveal = false;

            var breakpoint = new Adw.Breakpoint (
                Adw.BreakpointCondition.parse ("max-width: 550sp")
            );
            breakpoint.add_setter (view_switcher, "visible", false);
            breakpoint.add_setter (view_switcher_bar, "reveal", true);
            add_breakpoint (breakpoint);

            var content_box = new Box (Orientation.VERTICAL, 0);
            content_box.append (header_bar);
            content_box.append (view_stack);
            content_box.append (view_switcher_bar);

            set_content (content_box);
        }
    }
}