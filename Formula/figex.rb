class Figex < Formula
  desc "Utility tool to export styles and icons from Figma using the Figma REST API"
  homepage "https://github.com/iodigital-com/figex"
  url "https://github.com/iodigital-com/figex/releases/download/1.0.36834034503/figex-1.0.36834034503.zip"
  sha256 "e1c29943498efec08276267acc1669ba7a0795c015c9da1d7910e492a860cb5a"
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
