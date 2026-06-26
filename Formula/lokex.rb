class Lokex < Formula
  desc "Utility tool to export localization strings from Lokalise"
  homepage "https://github.com/iodigital-com/lokex"
  url "https://github.com/iodigital-com/lokex/releases/download/1.0.23789322161/lokex-1.0.23789322161.zip"
  sha256 "71e8572b9d20a75c7c40a022f10072b562d81006ca0fed6a08e39d1ca810769e"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "openjdk"

  def install
    libexec.install Dir["*"]

    (bin/"lokex").write <<~EOS
      #!/bin/bash
      export JAVA_HOME="#{Formula["openjdk"].opt_prefix}"
      exec "$JAVA_HOME/bin/java" -jar "#{libexec}/lokex-cli-jvm-#{version}.jar" "$@"
    EOS
    (bin/"lokex").chmod 0755
  end

  test do
    output = shell_output("#{bin}/lokex -c /tmp/nonexistent.json 2>&1", 128)
    assert_match "No such file", output
  end
end
