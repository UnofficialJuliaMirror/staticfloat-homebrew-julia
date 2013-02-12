require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-4.0.2.tar.gz'
  sha1 '46b24a28eef4b040ea5a02d2c43e82e28b7d6195'

  depends_on "tbb" if build.include? 'with-tbb'
  depends_on "metis" if build.include? 'with-metis'
  depends_on "openblas-julia" if !build.include? 'with-accelerate'

  option "with-metis", "Compile in metis libraries"
  option 'with-accelerate', 'Compile against Accelerate/vecLib instead of OpenBLAS'
  
  keg_only "Conflicts with suite-sparse"

  def install
    # SuiteSparse doesn't like to build in parallel
    ENV.j1

    inreplace 'SuiteSparse_config/SuiteSparse_config.mk' do |s|
      # Put in the proper libraries
      s.change_make_var! "BLAS", "-lopenblas" if !build.include? 'with-accelerate'
      s.change_make_var! "BLAS", "-Wl,-framework -Wl,Accelerate" if build.include? 'with-accelerate'
      s.change_make_var! "LAPACK", "$(BLAS)"

      if build.include? "with-tbb"
        s.change_make_var! "SPQR_CONFIG", "-DHAVE_TBB"
        s.change_make_var! "TBB", "-ltbb"
      end

      if build.include? "with-metis"
        s.remove_make_var! "METIS_PATH"
        s.change_make_var! "METIS", Formula.factory("metis").lib + "libmetis.a"
      end

      # Installation
      s.change_make_var! "INSTALL_LIB", lib
      s.change_make_var! "INSTALL_INCLUDE", include
    end

    system "make library"

    lib.mkpath
    include.mkpath
    system "make install"
  end
end
