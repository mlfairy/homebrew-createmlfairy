# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
class Createmlfairy < Formula
  desc "A CLI wrapper around CreateML"
  homepage "mlfairy.com"
  url "https://github.com/mlfairy/createmlfairy.git",
      :tag      => "0.1.0",
      :revision => "f3ca7775c2d61025d0dea2a7ad3f1a5ab0d6f01f"
  head "https://github.com/mlfairy/createmlfairy.git"

  depends_on :xcode => ["11.0", :build]

  def install
    system "make install prefix=#{prefix}"
  end

  test do
    system "#{bin}/createmlfairy" "--version"
  end
end
