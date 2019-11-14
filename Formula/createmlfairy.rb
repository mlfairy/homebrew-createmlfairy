# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
class Createmlfairy < Formula
  desc "A CLI wrapper around CreateML"
  homepage "mlfairy.com"
  url "https://github.com/mlfairy/createmlfairy.git",
      :tag      => "0.1.0",
      :revision => "d87d4e9b1e2702abd211cfa214695a78be3b80d4"
  head "https://github.com/mlfairy/createmlfairy.git"

  depends_on :xcode => ["11.0", :build]

  def install
    system "make install prefix=#{prefix}"
  end

  test do
    system "#{bin}/createmlfairy" "--version"
  end
end
