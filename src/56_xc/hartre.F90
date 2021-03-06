!{\src2tex{textfont=tt}}
!!****f* ABINIT/hartre
!! NAME
!! hartre
!!
!! FUNCTION
!! Given rho(G), compute Hartree potential (=FFT of rho(G)/pi/(G+q)**2)
!! When cplex=1, assume q=(0 0 0), and vhartr will be REAL
!! When cplex=2, q must be taken into account, and vhartr will be COMPLEX
!!
!! COPYRIGHT
!! Copyright (C) 1998-2012 ABINIT group (DCA, XG, GMR).
!! This file is distributed under the terms of the
!! GNU General Public License, see ~abinit/COPYING
!! or http://www.gnu.org/copyleft/gpl.txt .
!! For the initials of contributors, see ~abinit/doc/developers/contributors.txt .
!!
!! NOTES
!! *Modified code to avoid if statements inside loops to skip G=0.
!!  Replaced if statement on G^2>gsqcut to skip G s outside where
!!  rho(G) should be 0.  Effect is negligible but gsqcut should be
!!  used to be strictly consistent with usage elsewhere in code.
!! *The speed-up is provided by doing a few precomputations outside
!!  the inner loop. One variable size array is needed for this (gq).
!!
!! INPUTS
!!  cplex= if 1, vhartr is REAL, if 2, vhartr is COMPLEX
!!  gmet(3,3)=metrix tensor in G space in Bohr**-2.
!!  gsqcut=cutoff value on G**2 for sphere inside fft box.
!!         (gsqcut=(boxcut**2)*ecut/(2.d0*(Pi**2))
!!  izero=if 1, unbalanced components of Vhartree(g) are set to zero
!!  mpi_enreg=information about MPI parallelization
!!  nfft=(effective) number of FFT grid points (for this processor)
!!  ngfft(18)=contain all needed information about 3D FFT, see ~abinit/doc/input_variables/vargs.htm#ngfft
!!  qphon(3)=reduced coordinates for the phonon wavelength (needed if cplex==2).
!!  rhog(2,nfft)=electron density in G space
!!
!! OUTPUT
!!  vhartr(cplex*nfft)=Hartree potential in real space, either REAL or COMPLEX
!!
!! PARENTS
!!      ftfvw2,loop3dte,nres2vres,prctfvw2,rdm,rhohxc,rhotov3,setup_positron
!!      tddft
!!
!! CHILDREN
!!      fourdp,leave_new,timab,wrtout,zerosym
!!
!! SOURCE

#if defined HAVE_CONFIG_H
#include "config.h"
#endif

#include "abi_common.h"

subroutine hartre(cplex,gmet,gsqcut,izero,mpi_enreg,nfft,ngfft,paral_kgb,qphon,rhog,vhartr)

 use m_profiling

 use defs_basis
 use defs_abitypes

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'hartre'
 use interfaces_14_hidewrite
 use interfaces_16_hideleave
 use interfaces_18_timing
 use interfaces_53_ffts
!End of the abilint section

 implicit none

!Arguments ------------------------------------
!scalars
 integer,intent(in) :: cplex,izero,nfft,paral_kgb
 real(dp),intent(in) :: gsqcut
 type(MPI_type),intent(inout) :: mpi_enreg
!arrays
 integer,intent(in) :: ngfft(18)
 real(dp),intent(in) :: gmet(3,3),qphon(3),rhog(2,nfft)
 real(dp),intent(out) :: vhartr(cplex*nfft)

!Local variables-------------------------------
!scalars
 integer,parameter :: im=2,re=1
 integer :: i1,i2,i23,i3,id1,id2,id3
 integer :: ig,ig1min,ig1,ig1max,ig2,ig2min,ig2max,ig3,ig3min,ig3max
 integer :: ii,ii1,ing,n1,n2,n3,qeq0,qeq05
 real(dp),parameter :: tolfix=1.000000001e0_dp
 real(dp) :: cutoff,den,gqg2p3,gqgm12,gqgm13,gqgm23,gs,gs2,gs3
 character(len=500) :: message
!arrays
 integer :: id(3)
 real(dp) :: tsec(2)
 real(dp),allocatable :: gq(:,:),work1(:,:)

! *************************************************************************
!
!DEBUG
!write(std_out,*)' hartre : enter '
!write(std_out,*)' cplex,nfft,ngfft',cplex,nfft,ngfft
!write(std_out,*)' gsqcut=',gsqcut
!write(std_out,*)' qphon=',qphon
!write(std_out,*)' gmet=',gmet
!write(std_out,*)' maxval rhog=',maxval(abs(rhog))
!ENDDEBUG

!Keep track of total time spent in hartre
 call timab(10,1,tsec)

!Check that cplex has an allowed value
 if(cplex/=1 .and. cplex/=2)then
   write(message, '(a,a,a,a,i3,a,a)' )ch10,&
&   ' hartre : BUG -',ch10,&
&   '  From the calling routine, cplex=',cplex,ch10,&
&   '  but the only value allowed are 1 and 2.'
   call wrtout(std_out,message,'COLL')
   call leave_new('COLL')
 end if

 n1=ngfft(1) ; n2=ngfft(2) ; n3=ngfft(3)

!Initialize a few quantities
 cutoff=gsqcut*tolfix
 qeq0=0;if(qphon(1)**2+qphon(2)**2+qphon(3)**2<1.d-15) qeq0=1
 qeq05=0
 if (qeq0==0) then
   if (abs(abs(qphon(1))-half)<tol12.or.abs(abs(qphon(2))-half)<tol12.or. &
&   abs(abs(qphon(3))-half)<tol12) qeq05=1
 end if

!If cplex=1 then qphon should be 0 0 0
 if (cplex==1.and. qeq0/=1) then
   write(message, '(a,a,a,a,3e12.4,a,a)' ) ch10,&
&   ' hartre: BUG -',ch10,&
&   '  cplex=1 but qphon=',qphon,ch10,&
&   '  qphon should be 0 0 0.'
   call wrtout(std_out,message,'COLL')
   call leave_new('COLL')
 end if

!If FFT parallelism then qphon should not be 1/2
 if (mpi_enreg%nproc_fft>1.and.qeq05==1) then
   write(message, '(a,a,a,a,3e12.4,a,a)' ) ch10,&
&   ' hartre: ERROR -',ch10,&
&   '  FFT parallelism selected but qphon=',qphon,ch10,&
&   '  qphon(i) should not be 1/2...'
   call wrtout(std_out,message,'COLL')
   call leave_new('COLL')
 end if

!In order to speed the routine, precompute the components of g+q
!Also check if the booked space was large enough...
 ABI_ALLOCATE(gq,(3,max(n1,n2,n3)))
 do ii=1,3
   id(ii)=ngfft(ii)/2+2
   do ing=1,ngfft(ii)
     ig=ing-(ing/id(ii))*ngfft(ii)-1
     gq(ii,ing)=ig+qphon(ii)
   end do
 end do
 ig1max=-1;ig2max=-1;ig3max=-1
 ig1min=n1;ig2min=n2;ig3min=n3

 ABI_ALLOCATE(work1,(2,nfft))
 id1=n1/2+2;id2=n2/2+2;id3=n3/2+2

!Triple loop on each dimension
 do i3=1,n3
   ig3=i3-(i3/id3)*n3-1
!  Precompute some products that do not depend on i2 and i1
   gs3=gq(3,i3)*gq(3,i3)*gmet(3,3)
   gqgm23=gq(3,i3)*gmet(2,3)*2
   gqgm13=gq(3,i3)*gmet(1,3)*2

   do i2=1,n2
     ig2=i2-(i2/id2)*n2-1
     if (((i2-1)/(n2/mpi_enreg%nproc_fft))==mpi_enreg%me_fft) then
       gs2=gs3+ gq(2,i2)*(gq(2,i2)*gmet(2,2)+gqgm23)
       gqgm12=gq(2,i2)*gmet(1,2)*2
       gqg2p3=gqgm13+gqgm12

       i23=n1*(i2-mpi_enreg%me_fft*n2/mpi_enreg%nproc_fft-1+(n2/mpi_enreg%nproc_fft)*(i3-1))
!      Do the test that eliminates the Gamma point outside
!      of the inner loop
       ii1=1
       if(i23==0 .and. qeq0==1  .and. ig2==0 .and. ig3==0)then
         ii1=2
         work1(re,1+i23)=zero
         work1(im,1+i23)=zero
       end if

!      Final inner loop on the first dimension (note the lower limit)
       do i1=ii1,n1
         gs=gs2+ gq(1,i1)*(gq(1,i1)*gmet(1,1)+gqg2p3)
         ii=i1+i23
         if(gs<=cutoff)then

!          Identify min/max indexes (to cancel unbalanced contributions later)
!          Count (q+g)-vectors with similar norm
           if ((qeq05==1).and.(izero==1)) then
             ig1=i1-(i1/id1)*n1-1
             ig1max=max(ig1max,ig1);ig1min=min(ig1min,ig1)
             ig2max=max(ig2max,ig2);ig2min=min(ig2min,ig2)
             ig3max=max(ig3max,ig3);ig3min=min(ig3min,ig3)
           end if

           den=piinv/gs
           work1(re,ii)=rhog(re,ii)*den
           work1(im,ii)=rhog(im,ii)*den

         else ! gs>cutoff
           work1(re,ii)=zero
           work1(im,ii)=zero
         end if
!        End loop on i1
       end do
     end if
!    End loop on i2
   end do

!  End loop on i3
 end do

 ABI_DEALLOCATE(gq)

!DEBUG
!write(std_out,*)' hartre : before fourdp'
!write(std_out,*)' cplex,nfft,ngfft',cplex,nfft,ngfft
!write(std_out,*)' maxval work1=',maxval(abs(work1))
!ENDDEBUG

!Set contribution of unbalanced components to zero
 if (izero==1) then
   if (qeq0==1) then       !q=0
     call zerosym(work1,2,mpi_enreg,n1,n2,n3)
   else if (qeq05==1) then !q=1/2; this doesn't work in parallel
     ig1=-1;if (mod(n1,2)==0) ig1=1+n1/2
     ig2=-1;if (mod(n2,2)==0) ig2=1+n2/2
     ig3=-1;if (mod(n3,2)==0) ig3=1+n3/2
     if (abs(abs(qphon(1))-half)<tol12) then
       if (abs(ig1min)<abs(ig1max)) ig1=abs(ig1max)
       if (abs(ig1min)>abs(ig1max)) ig1=n1-abs(ig1min)
     end if
     if (abs(abs(qphon(2))-half)<tol12) then
       if (abs(ig2min)<abs(ig2max)) ig2=abs(ig2max)
       if (abs(ig2min)>abs(ig2max)) ig2=n2-abs(ig2min)
     end if
     if (abs(abs(qphon(3))-half)<tol12) then
       if (abs(ig3min)<abs(ig3max)) ig3=abs(ig3max)
       if (abs(ig3min)>abs(ig3max)) ig3=n3-abs(ig3min)
     end if
     call zerosym(work1,2,mpi_enreg,n1,n2,n3,ig1=ig1,ig2=ig2,ig3=ig3)
   end if
 end if

!Fourier Transform Vhartree.
!Vh in reciprocal space was stored in work1
 call fourdp(cplex,work1,vhartr,1,mpi_enreg,nfft,ngfft,paral_kgb,0)

!DEBUG
!write(std_out,*)' hartre : after fourdp'
!write(std_out,*)' cplex,nfft,ngfft',cplex,nfft,ngfft
!write(std_out,*)' maxval rhog=',maxval(abs(rhog))
!write(std_out,*)' maxval work1=',maxval(abs(work1))
!write(std_out,*)' maxval vhartr=',maxval(abs(vhartr))
!write(std_out,*)' hartre : set vhartr to zero'
!vhartr(:)=zero
!ENDDEBUG

 ABI_DEALLOCATE(work1)

 call timab(10,2,tsec)

end subroutine hartre
!!***
