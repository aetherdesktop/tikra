using Gtk;
using Adw;

namespace Tikra {
    public class Application : Adw.Application {
        public Application () {
            Object (
                application_id: "org.aether.tikra",
                flags: ApplicationFlags.DEFAULT_FLAGS
            );
        }

        public override void activate () {
            base.activate ();

            var main_window = this.active_window;
            if (main_window == null) {
                main_window = new MainWindow (this);
            }

            main_window.present ();
        }

        public override void startup () {
            base.startup ();

            // Load custom CSS - using inline styles for now
            var css_provider = new Gtk.CssProvider ();
            var css_data = """
            /* Tikra Clock Application Custom Styles */
            
            .time-display {
              background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
              border: 1px solid rgba(255,255,255,0.1);
              box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            }
            
            .time-large {
              font-size: 3.5em;
              font-weight: 300;
              letter-spacing: 0.1em;
            }
            
            .card {
              border-radius: 16px;
              transition: all 200ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
            }
            
            .card:hover {
              box-shadow: 0 12px 48px rgba(0,0,0,0.15);
              transform: translateY(-2px);
            }
            
            .pill {
              min-width: 120px;
              min-height: 40px;
              border-radius: 20px;
              font-weight: 600;
              transition: all 200ms ease;
            }
            
            .pill:hover {
              transform: translateY(-1px);
              box-shadow: 0 4px 16px rgba(0,0,0,0.2);
            }
            
            .numeric {
              font-variant-numeric: tabular-nums;
              font-feature-settings: "tnum";
            }
            
            .dim-label {
              opacity: 0.7;
            }
            
            .accent {
              color: @accent_color;
              font-weight: 600;
            }
            """;
            
            css_provider.load_from_string (css_data);
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            var quit_action = new SimpleAction ("quit", null);
            quit_action.activate.connect (quit);
            add_action (quit_action);
            set_accels_for_action ("app.quit", {"<Control>q"});

            var about_action = new SimpleAction ("about", null);
            about_action.activate.connect (show_about);
            add_action (about_action);
        }

        private void show_about () {
            var about = new Adw.AboutDialog () {
                application_name = "Tikra",
                application_icon = "org.aether.tikra",
                developer_name = "AnmiTaliDev",
                version = "0.2.0",
                comments = "A simple clock application for AetherDE",
                copyright = "© 2025 AnmiTaliDev",
                license_type = License.GPL_3_0,
                website = "https://github.com/NurOS-Linux/tikra"
            };
            about.add_link ("Repository", "https://github.com/NurOS-Linux/tikra");
            about.developers = {"AnmiTaliDev <anmitali198@gmail.com>"};
            about.present (this.active_window);
        }
    }
}
