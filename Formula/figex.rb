class Figex < Formula
  desc "Utility tool to export styles and icons from Figma using the Figma REST API"
  homepage "https://github.com/iodigital-com/figex"
  url "https://github.com/iodigital-com/figex/releases/download/1.0.28937192168/figex-1.0.28937192168.zip"
  sha256 "05bf3fe9b5a6459808057497ef343d7375233facc57a4182a09ba96fd14b6da1"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "openjdk"

  def install
    libexec.install Dir["*"]

    (bin/"figex").write <<~EOS
      #!/bin/bash
      export JAVA_HOME="#{Formula["openjdk"].opt_prefix}"
      exec "$JAVA_HOME/bin/java" -jar "#{libexec}/figex-cli-jvm-#{version}.jar" "$@"
    EOS
    (bin/"figex").chmod 0755
  end

  test do
    output = shell_output("#{bin}/figex -c /tmp/nonexistent.json 2>&1", 128)
    assert_match "Config file does not exist", output
  end
end
