{ lib, hostPkgs, ... }:

let
  # Make sure we don't have to go through the startup tutorial
  customMuseScoreConfig = hostPkgs.writeText "MuseScore4.ini" ''
    [application]
    hasCompletedFirstLaunchSetup=true

    [project]
    preferredScoreCreationMode=1
  '';
in
{
  name = "musescore";
  meta = with lib.maintainers; {
    maintainers = [ turion ];
  };

  nodes.machine =
    { pkgs, ... }:
    {
      imports = [
        ./common/x11.nix
      ];

      services.xserver.enable = true;
      environment.systemPackages = with pkgs; [
        musescore
        pdfgrep
      ];
    };

  enableOCR = true;

  testScript =
    { ... }:
    ''
      start_all()
      machine.wait_for_x()

      # Inject custom settings
      machine.succeed("mkdir -p /root/.config/MuseScore/")
      machine.succeed(
          "cp ${customMuseScoreConfig} /root/.config/MuseScore/MuseScore4.ini"
      )

      # Start MuseScore window
      machine.execute("env XDG_RUNTIME_DIR=$PWD DISPLAY=:0.0 mscore >&2 &")

      # Wait until MuseScore has launched
      machine.wait_for_window("MuseScore Studio")

      machine.screenshot("MuseScore0")

      # Create a new score
      machine.send_key("ctrl-n")

      # Wait until the creation wizard appears
      machine.wait_for_window("New score")

      machine.screenshot("MuseScore1")

      machine.send_key("tab")
      machine.send_key("tab")
      machine.send_key("ret")

      machine.sleep(2)

      machine.send_key("tab")
      # Type the beginning of https://de.wikipedia.org/wiki/Alle_meine_Entchen
      machine.send_chars("cdef6gg5aaaa7g")
      machine.sleep(1)

      machine.screenshot("MuseScore2")

      # Go to the export dialogue and create a PDF
      machine.send_key("ctrl-p")

      # Wait until the Print dialogue appears.
      machine.wait_for_window("Print")

      machine.screenshot("MuseScore4")
      machine.send_key("alt-p")
      machine.sleep(1)

      machine.screenshot("MuseScore5")

      # Wait until PDF is exported
      machine.wait_for_file('"/root/Untitled score.pdf"')

      ## Check that it contains the title of the score
      machine.succeed('pdfgrep "Untitled score" "/root/Untitled score.pdf"')
      machine.copy_from_vm("/root/Untitled score.pdf")
    '';
}
