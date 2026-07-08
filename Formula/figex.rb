class Figex < Formula
  desc "Utility tool to export styles and icons from Figma using the Figma REST API"
  homepage "https://github.com/iodigital-com/figex"
  url "https://github.com/iodigital-com/figex/releases/download/1.0.28947845188/figex-1.0.28947845188.zip"
  sha256 "7aafc9d04c17480dd671018cd4187cf5e7ed148f4351b8887fa5485cec0f1d6a"
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
