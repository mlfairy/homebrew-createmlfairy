# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
class Createmlfairy < Formula
  desc "A CLI wrapper around CreateML"
  homepage "mlfairy.com"
  url "https://github.com/mlfairy/createmlfairy"
  version "0.1.0"

  depends_on :xcode => ["11.0", :build]

  def install
    system "make install prefix=#{prefix}"
  end

  test do
    system "#{bin}/createmlfairy" "--version"
  end
end
