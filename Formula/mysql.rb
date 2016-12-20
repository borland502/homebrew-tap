class Mysql < Formula
  desc "Relational database management system"
  homepage "https://dev.mysql.com/doc/refman/5.7/en/"
  url "https://cdn.mysql.com/Downloads/MySQL-5.7/mysql-boost-5.7.17.tar.gz"
  sha256 "b75bba87199ef6a6ccc5dfbcaf70949009dc12089eafad8c5254afc9002aa903"

  depends_on "cmake" => :build
  depends_on macos: :mavericks
  depends_on "openssl"

  def install
    # Don't hard-code the libtool path. See:
    # https://github.com/Homebrew/homebrew/issues/20185
    inreplace "cmake/libutils.cmake",
      "COMMAND /usr/bin/libtool -static -o ${TARGET_LOCATION}",
      "COMMAND libtool -static -o ${TARGET_LOCATION}"

    # -DINSTALL_* are relative to prefix
    args = %W[
      -DBUILD_CONFIG=mysql_release
      -DFEATURE_SET=community
      -DINSTALL_DOCDIR=share/doc/#{name}
      -DINSTALL_INCLUDEDIR=include/mysql
      -DINSTALL_INFODIR=share/info
      -DINSTALL_MANDIR=share/man
      -DINSTALL_MYSQLSHAREDIR=share/mysql
      -DINSTALL_MYSQLTESTDIR=
      -DINSTALL_PLUGINDIR=lib/mysql/plugin
      -DINSTALL_SCRIPTDIR=bin
      -DINSTALL_SUPPORTFILESDIR=share/mysql
      -DMYSQL_DATADIR=#{var}/db/mysql
      -DSYSCONFDIR=#{etc}
      -DDEFAULT_CHARSET=utf8
      -DDEFAULT_COLLATION=utf8_general_ci
      -DENABLED_LOCAL_INFILE=ON
      -DWITH_DEBUG=OFF
      -DWITH_EMBEDDED_SERVER=OFF
      -DWITH_EDITLINE=system
      -DWITH_INNOBASE_STORAGE_ENGINE=1
      -DWITH_SSL=system
      -DWITH_BOOST=boost
    ]

    system "cmake", ".", *std_cmake_args, *args
    system "make"
    system "make", "install"

    # Don't create databases inside of the prefix!
    # See: https://github.com/Homebrew/homebrew/issues/4975
    rm_rf prefix/"data"

    # Fix up the control script and link into bin
    inreplace "#{pkgshare}/mysql.server" do |s|
      s.gsub!(/^(PATH=".*)(")/, "\\1:#{HOMEBREW_PREFIX}/bin\\2")
      # pidof can be replaced with pgrep from proctools on Mountain Lion
      s.gsub!(/pidof/, "pgrep")
    end
    bin.install_symlink prefix/"share/mysql/mysql.server"
  end

  def post_install
    # Make sure the run-time directories exist
    %w[db/mysql log run].each { |p| (var+p).mkpath }
  end

  test do
    system bin/"mysqld", "--version"
  end
end
