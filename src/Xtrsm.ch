/**
  -- (C) Copyright 2016 King Abdullah University of Science and Technology
  Authors:
  Ali Charara (ali.charara@kaust.edu.sa)
  David Keyes (david.keyes@kaust.edu.sa)
  Hatem Ltaief (hatem.ltaief@kaust.edu.sa)

  Redistribution  and  use  in  source and binary forms, with or without
  modification,  are  permitted  provided  that the following conditions
  are met:

  * Redistributions  of  source  code  must  retain  the above copyright
  * notice,  this  list  of  conditions  and  the  following  disclaimer.
  * Redistributions  in  binary  form must reproduce the above copyright
  * notice,  this list of conditions and the following disclaimer in the
  * documentation  and/or other materials provided with the distribution.
  * Neither  the  name of the King Abdullah University of Science and
  * Technology nor the names of its contributors may be used to endorse
  * or promote products derived from this software without specific prior
  * written permission.
  *
  THIS  SOFTWARE  IS  PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ``AS IS''  AND  ANY  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A  PARTICULAR  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL,  EXEMPLARY,  OR  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT NOT
  LIMITED  TO,  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA,  OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY  OF  LIABILITY,  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF  THIS  SOFTWARE,  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

  CBLAS_TRANSPOSE noTrans = CblasNoTrans;
  if(side == CblasLeft){

    //TODO(*alpha == make_zero<T>())
    if( SIMPLE_SIZE_TRSM(m) ){
      cblas_Xtrsm(order, side, uplo, trans, diag,
                  m, n,
                  alpha, A_, lda,
                         B_, ldb );
      return;
    }

    int m1, m2;
    if(REG_SIZE(m))
      m1 = m2 = m/2;
    else{
      m1 = CLOSEST_REG_SIZE(m);
      m2 = m-m1;
    }

    if(uplo == CblasUpper){

      //Left / Upper / NoTrans
      if(trans == CblasNoTrans){
        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m2, n,
                    alpha, A(m1,m1), lda,
                           B(m1,0), ldb);

        cblas_Xgemm(order, trans, noTrans,
                    m1, n, m2,
                    mone, A(0,m1), lda,
                          B(m1,0), ldb,
                    alpha, B_, ldb);

        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m1, n,
                    one, A_, lda,
                         B_, ldb);
      }
      //Left / Upper / [Conj]Trans
      else{
        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m1, n,
                    alpha, A_, lda,
                           B_, ldb);

        cblas_Xgemm(order, trans, noTrans,
                    m2, n, m1,
                    mone, A(0,m1), lda,
                          B_, ldb,
                    alpha, B(m1,0), ldb);

        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m2, n,
                    one, A(m1,m1), lda,
                         B(m1,0), ldb);
      }
    }else{//uplo == KBLAS_Lower

      //Left / Lower / NoTrans
      if(trans == CblasNoTrans){
        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m1, n,
                    alpha, A_, lda,
                           B_, ldb);

        cblas_Xgemm(order, trans, noTrans,
                    m2, n, m1,
                    mone, A(m1,0), lda,
                          B_, ldb,
                    alpha, B(m1,0), ldb);

        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m2, n,
                    one, A(m1,m1), lda,
                         B(m1,0), ldb);
      }
      //Left / Lower / [Conj]Trans
      else{//transa == KBLAS_Trans

        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m2, n,
                    alpha, A(m1,m1), lda,
                           B(m1,0), ldb);

        cblas_Xgemm(order, trans, noTrans,
                    m1, n, m2,
                    mone, A(m1,0), lda,
                          B(m1,0), ldb,
                    alpha, B_, ldb);

        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m1, n,
                    one, A_, lda,
                         B_, ldb);
      }//transa == KBLAS_Trans
    }
  }
  else{//side == KBLAS_Right
    int n1, n2;
    if( SIMPLE_SIZE_TRSM(n) ){
      cblas_Xtrsm(order, side, uplo, trans, diag,
                  m, n,
                  alpha, A_, lda,
                         B_, ldb );
      return;
    }

    if(REG_SIZE(n))
      n1 = n2 = n/2;
    else{
      n1 = CLOSEST_REG_SIZE(n);
      n2 = n-n1;
    }

    if(uplo == CblasUpper){
      //Right / Upper / NoTrans
      if(trans == noTrans){
        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m, n1,
                    alpha, A_, lda,
                           B_, ldb);

        cblas_Xgemm(order, noTrans, trans,
                    m, n2, n1,
                    mone, B_, ldb,
                          A(0,n1), lda,
                    alpha, B(0,n1), ldb);

        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m, n2,
                    one, A(n1,n1), lda,
                         B(0,n1), ldb);
      }
      //Right / Upper / [Conj]Trans
      else{
        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m, n2,
                    alpha, A(n1,n1), lda,
                           B(0,n1), ldb);

        cblas_Xgemm(order, noTrans, trans,
                    m, n1, n2,
                    mInvAlpha, B(0,n1), ldb,
                               A(0,n1), lda,
                    one,       B_, ldb);

        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m, n1,
                    alpha, A_, lda,
                           B_, ldb);
      }
    }
    else{
      //Right / Lower / NoTrans
      if(trans == noTrans){
        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m, n2,
                    alpha, A(n1,n1), lda,
                           B(0,n1), ldb);

        cblas_Xgemm(order, noTrans, trans,
                    m, n1, n2,
                    mone, B(0,n1), ldb,
                          A(n1,0), lda,
                    alpha, B_, ldb);

        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m, n1,
                    one, A_, lda,
                         B_, ldb);
      }
      //Right / Lower / [Conj]Trans
      else{
        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m, n1,
                    alpha, A_, lda,
                           B_, ldb);

        cblas_Xgemm(order, noTrans, trans,
                    m, n2, n1,
                    mInvAlpha, B_, ldb,
                               A(n1,0), lda,
                    one,       B(0,n1), ldb);

        kblas_Xtrsm(order, side, uplo, trans, diag,
                    m, n2,
                    alpha, A(n1,n1), lda,
                           B(0,n1), ldb);
      }
    }
  }



