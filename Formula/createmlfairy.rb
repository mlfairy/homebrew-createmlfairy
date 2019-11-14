# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
class Createmlfairy < Formula
  desc "A CLI wrapper around CreateML"
  homepage "mlfairy.com"
  url "https://github.com/mlfairy/homebrew-createmlfairy.git",
      :tag      => "0.3.0",
      :revision => "8510b14fa16cb9e483297b534068782989cb6b8c"
  head "https://github.com/mlfairy/homebrew-createmlfairy.git"

  depends_on :xcode => ["11.0", :build]

  def install
    system "make install prefix=#{prefix}"
  end

  test do
    system "#{bin}/createmlfairy" "--version"
  end
end
