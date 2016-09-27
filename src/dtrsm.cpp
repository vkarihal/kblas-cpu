

#include <set>
#include <stdio.h>
#include <string>
#include "cblas.h"
#include "Xtr_common.ch"
//#include "cholinv_util.h"


//==============================================================================================

#define A(r_,c_) A_+(order == CblasColMajor ? (r_)+(c_)*lda : (r_)*lda+(c_) )
#define B(r_,c_) B_+(order == CblasColMajor ? (r_)+(c_)*ldb : (r_)*ldb+(c_) )
#define kblas_Xtrsm kblas_dtrsm
#define cblas_Xtrsm cblas_dtrsm
#define cblas_Xgemm cblas_dgemm

void kblas_dtrsm(const enum CBLAS_ORDER order,
                 const enum CBLAS_SIDE side, const enum CBLAS_UPLO uplo,
                 const enum CBLAS_TRANSPOSE trans, const enum CBLAS_DIAG diag,
                 const int m, const int n,
                 const double alpha, const double *A_, const int lda,
                                           double *B_, const int ldb){

  double one = 1.0;
  double mone = -1.0;
  double mInvAlpha = mone / alpha;

#include "Xtrsm.ch"
  
}