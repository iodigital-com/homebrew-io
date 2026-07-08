class Claudio < Formula
  desc "CLI for switching between Claude Code projects with different API keys"
  homepage "https://github.com/iodigital-com/claudio"
  url "https://github.com/iodigital-com/claudio/archive/refs/tags/0.2.0.tar.gz"
  sha256 "7d701f793fd1abd5c4a7ecd319b6a6851e161df7cafb6c79e06e272c9c22763e"
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
