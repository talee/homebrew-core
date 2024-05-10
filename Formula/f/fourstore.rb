class Fourstore < Formula
  desc "Efficient, stable RDF database"
  homepage "https://github.com/4store/4store"
  # NOTE: Try building without `avahi` at version bump.
  url "https://github.com/4store/4store/archive/refs/tags/v1.1.7.tar.gz"
  sha256 "e511f1adb094e2506545d4773a6005a462f6b4532731e91f1115b038ab25a8f0"
  license "GPL-3.0-or-later"

  bottle do
    sha256 arm64_sonoma:   "b5595483be41d447472e43bedb18b3ca3a04ce88e42f50ee0841be09b27a11b3"
    sha256 arm64_ventura:  "5909b28a48725eacea49092ef49e8865ab7c66c7e5c9b6ba5679f02388d99434"
    sha256 arm64_monterey: "7aed20fb578c260f7d1764679d6ecaad032d68dd6bdacca012002ea815509a4a"
    sha256 arm64_big_sur:  "ad26cc8bd35c75d1988f97de3fbf3281061afc8002a082d61e99800168c5f4c3"
    sha256 sonoma:         "18986922d034c80b22c77e8bc32e048115e2ece3c47bb635f85f6c108a394de2"
    sha256 ventura:        "307193f0a58ed4cb29bb064654a32d3412a5051e57f6392c99872a2776525722"
    sha256 monterey:       "6323983ec1a097a3a6a0473232531037223957d4c41ff2a5514315a7a21fb1af"
    sha256 big_sur:        "045a48f298bedfd23a4fc9d93191de328f686c4fea889a926e5f8b2d6e65baa7"
    sha256 catalina:       "e292048a085d8583547af82380dfcadbb92c15d28e56a75ae909ef853d363391"
    sha256 x86_64_linux:   "5a43f121222346aa9f89b8ed1609656ab0fbb696d05f719989ae751e0cae34b2"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "dbus"
  depends_on "gettext"
  depends_on "glib"
  depends_on "pcre"
  depends_on "raptor"
  depends_on "rasqal"
  depends_on "readline"

  def install
    # Work around failure from GCC 10+ using default of `-fno-common`
    # /usr/bin/ld: query.o:(.bss+0x0): multiple definition of `rasqal_mutex'
    ENV.append_to_cflags "-fcommon" if OS.linux?
    # Upstream issue https://github.com/4store/4store/issues/138
    # Otherwise .git directory is needed
    (buildpath/".version").write version.to_s

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}",
                          "--with-storage-path=#{var}/fourstore",
                          "--sysconfdir=#{etc}/fourstore"
    system "make", "install"
  end

  def post_install
    (var/"fourstore").mkpath
  end

  def caveats
    <<~EOS
      Databases will be created at #{var}/fourstore.

      Create and start up a database:
          4s-backend-setup mydb
          4s-backend mydb

      Load RDF data:
          4s-import mydb datafile.rdf

      Start up HTTP SPARQL server without daemonizing:
          4s-httpd -p 8000 -D mydb

      See https://4store.danielknoell.de/trac/wiki/Documentation/ for more information.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/4s-admin --version")
  end
end
