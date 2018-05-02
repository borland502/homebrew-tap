class CacheDownloadStrategy < CurlDownloadStrategy
  def fetch
    archive = @url.sub(%r[^file://], "")
    unless File.exists?(archive)
      odie <<~EOS
        Formula expects to locate the following archive:
          #{Pathname.new(archive).basename}

        in the HOMEBREW_CACHE directory:
          #{HOMEBREW_CACHE}

        Copy the archive to the cache or create a symlink in the cache to the archive:
          ln -sf /path/to/archive $(brew --cache)/
      EOS
    end
    super
  end
end

class Sqlcl < Formula
  desc "Free, Java-based command-line interface for Oracle databases"
  homepage "https://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html"
  url "file://#{HOMEBREW_CACHE}/sqlcl-18.1.1.zip",
    using: CacheDownloadStrategy
  sha256 "3180aab7886222a5ffeb2578c68ba8c835d00400560a6f79dbf7cb6f02f242d5"

  bottle :unneeded

  depends_on java: "1.8"

  def install
    # Remove Windows files
    rm_f "bin/sql.exe"

    prefix.install "bin/README.md"
    rm_f "bin/README.md"

    libexec.install %w[bin lib]
    bin.write_exec_script Dir["#{libexec}/bin/sql"]
    bin.env_script_all_files(libexec/"bin", Language::Java.java_home_env("1.8"))
    mv "#{bin}/sql", "#{bin}/sqlcl"
  end

  test do
    system bin/"sqlcl", "-V"
  end
end
