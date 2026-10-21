class Claudio < Formula
  desc "CLI for switching between Claude Code projects with different API keys"
  homepage "https://github.com/iodigital-com/claudio"
  url "https://github.com/iodigital-com/claudio/archive/refs/tags/1.0.tar.gz"
  sha256 "0852ebdb50bfc432aebedc6f2630a1c1d44166270c966e684597af689f9a536f"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "uv"
  depends_on "python@3.13"

  def install
    system "uv", "venv", libexec, "--python", Formula["python@3.13"].opt_bin/"python3.13"
    system "uv", "pip", "install", buildpath, "--python", libexec/"bin/python"
    (bin/"claudio").write_env_script libexec/"bin/claudio", PATH: "#{libexec}/bin:$PATH"
  end

  test do
    system bin/"claudio", "--help"
  end
end
