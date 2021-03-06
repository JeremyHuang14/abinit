!{\src2tex{textfont=tt}}
!!****f* ABINIT/xexch_mpi_intn
!! NAME
!!  xexch_mpi_intn
!!
!! FUNCTION
!!  This module contains functions that calls MPI routine,
!!  if we compile the code using the MPI CPP flags.
!!  xexch_mpi is the generic function.
!!  Note that there exist two versions of the xexch_mpi,
!!  irrespective of the kind of data that is exchanged : in a first version,
!!  one suppose that there will be no confusion between different messages exchanged
!!  between a pair (sender,receiver), so that no message tag is to be specified
!!  (one tag will be automatically generated), while in the second version (safer !),
!!  a tag is specified.
!!
!! COPYRIGHT
!!  Copyright (C) 2001-2012 ABINIT group (MB)
!!  This file is distributed under the terms of the
!!  GNU General Public License, see ~ABINIT/COPYING
!!  or http://www.gnu.org/copyleft/gpl.txt .
!!
!! NOTE 
!!  In the version with a tag automatically generated, the tag conforms
!!  to the MPI request that the tag is lower than 32768, by using a modulo call.
!!
!! TODO
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE

#if defined HAVE_CONFIG_H
#include "config.h"
#endif

!--------------------------------------------------------------------

subroutine xexch_mpi_intn(vsend,n1,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_intn'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) :: n1
 integer,intent(in) :: vsend(:)
 integer,intent(inout) :: vrecv(:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: statux(MPI_STATUS_SIZE)
 integer :: tag,me
#endif
! *************************************************************************

 ier=0

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL ) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 tag = MOD(n1,xmpi_tag_ub+1) 
 if ( recever == me ) then
   call MPI_RECV(vrecv,n1,MPI_INTEGER,sender,tag,spaceComm,statux,ier)
 end if
 if ( sender == me ) then
   call MPI_SEND(vsend,n1,MPI_INTEGER,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_intn
!!***

!--------------------------------------------------------------------

!!****f* ABINIT/xexch_mpi_int2d
!! NAME
!!  xexch_mpi_int2d
!!
!! FUNCTION
!!  Sends and receives data.
!!  Target: two-dimensional integer arrays.
!!
!! INPUTS
!!  nt= vector length
!!  vsend= send buffer
!!  sender= node sending the data
!!  recever= node receiving the data
!!  spaceComm= MPI communicator
!!
!! OUTPUT
!!  ier= exit status, a non-zero value meaning there is an error
!!
!! SIDE EFFECTS
!!  vrecv= receive buffer
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE
subroutine xexch_mpi_int2d(vsend,nt,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_int2d'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) :: nt
 integer,intent(in) :: vsend(:,:)
 integer,intent(inout) :: vrecv(:,:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: statux(MPI_STATUS_SIZE)
 integer :: tag,me
#endif
! *************************************************************************

 ier=0

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL ) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 tag = MOD(nt, xmpi_tag_ub+1)
 if ( recever == me ) then
   call MPI_RECV(vrecv,nt,MPI_INTEGER,sender,tag,spaceComm,statux,ier)
 end if
 if ( sender == me ) then
   call MPI_SEND(vsend,nt,MPI_INTEGER,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_int2d
!!***

!--------------------------------------------------------------------

!!****f* ABINIT/xexch_mpi_dpn
!! NAME
!!  xexch_mpi_dpn
!!
!! FUNCTION
!!  Sends and receives data.
!!  Target: one-dimensional double precision arrays.
!!
!! INPUTS
!!  n1= first dimension of the array
!!  vsend= send buffer
!!  sender= node sending the data
!!  recever= node receiving the data
!!  spaceComm= MPI communicator
!!
!! OUTPUT
!!  ier= exit status, a non-zero value meaning there is an error
!!
!! SIDE EFFECTS
!!  vrecv= receive buffer
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE
subroutine xexch_mpi_dpn(vsend,n1,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_dpn'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) :: n1
 real(dp),intent(in) :: vsend(:)
 real(dp),intent(inout) :: vrecv(:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: statux(MPI_STATUS_SIZE)
 integer :: tag,me
#endif
! *************************************************************************

 ier=0

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL ) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 tag = MOD(n1, xmpi_tag_ub+1)
 if ( recever == me ) then
   call MPI_RECV(vrecv,n1,MPI_DOUBLE_PRECISION,sender,tag,spaceComm,statux,ier)
 end if
 if ( sender == me ) then
   call MPI_SEND(vsend,n1,MPI_DOUBLE_PRECISION,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_dpn
!!***

!--------------------------------------------------------------------

!!****f* ABINIT/xexch_mpi_dp2d
!! NAME
!!  xexch_mpi_dp2d
!!
!! FUNCTION
!!  Sends and receives data.
!!  Target: double precision two-dimensional arrays.
!!
!! INPUTS
!!  nt= vector length
!!  vsend= send buffer
!!  sender= node sending the data
!!  recever= node receiving the data
!!  spaceComm= MPI communicator
!!
!! OUTPUT
!!  ier= exit status, a non-zero value meaning there is an error
!!
!! SIDE EFFECTS
!!  vrecv= receive buffer
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE
subroutine xexch_mpi_dp2d(vsend,nt,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_dp2d'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) :: nt
 real(dp),intent(in) :: vsend(:,:)
 real(dp),intent(inout) :: vrecv(:,:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: statux(MPI_STATUS_SIZE)
 integer :: tag,me
#endif
! *************************************************************************

 ier=0

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL ) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 tag=MOD(nt, xmpi_tag_ub+1)
 if ( recever == me ) then
   call MPI_RECV(vrecv,nt,MPI_DOUBLE_PRECISION,sender,tag,spaceComm,statux,ier)
 end if
 if ( sender == me ) then
   call MPI_SEND(vsend,nt,MPI_DOUBLE_PRECISION,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_dp2d
!!***

!--------------------------------------------------------------------

!!****f* ABINIT/xexch_mpi_dp3d
!! NAME
!!  xexch_mpi_dp3d
!!
!! FUNCTION
!!  Sends and receives data.
!!  Target: double precision three-dimensional arrays.
!!
!! INPUTS
!!  nt= vector length
!!  vsend= send buffer
!!  sender= node sending the data
!!  recever= node receiving the data
!!  spaceComm= MPI communicator
!!
!! OUTPUT
!!  ier= exit status, a non-zero value meaning there is an error
!!
!! SIDE EFFECTS
!!  vrecv= receive buffer
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE
subroutine xexch_mpi_dp3d(vsend,nt,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_dp3d'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) :: nt
 real(dp),intent(in) :: vsend(:,:,:)
 real(dp),intent(inout) :: vrecv(:,:,:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: statux(MPI_STATUS_SIZE)
 integer :: tag,me
#endif
! *************************************************************************

 ier=0

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL ) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 tag=MOD(nt, xmpi_tag_ub+1)
 if ( recever == me ) then
   call MPI_RECV(vrecv,nt,MPI_DOUBLE_PRECISION,sender,tag,spaceComm,statux,ier)
 end if
 if ( sender == me ) then
   call MPI_SEND(vsend,nt,MPI_DOUBLE_PRECISION,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_dp3d
!!***

!--------------------------------------------------------------------

!!****f* ABINIT/xexch_mpi_dp4d_tag
!! NAME
!!  xexch_mpi_dp4d_tag
!!
!! FUNCTION
!!  Sends and receives data.
!!  Target: double precision four-dimensional arrays.
!!
!! INPUTS
!!  mtag= message tag
!!  vsend= send buffer
!!  sender= node sending the data
!!  recever= node receiving the data
!!  spaceComm= MPI communicator
!!
!! OUTPUT
!!  ier= exit status, a non-zero value meaning there is an error
!!
!! SIDE EFFECTS
!!  vrecv= receive buffer
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE
subroutine xexch_mpi_dp4d_tag(vsend,mtag,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_dp4d_tag'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) :: mtag 
 real(dp),intent(in) :: vsend(:,:,:,:)
 real(dp),intent(inout) :: vrecv(:,:,:,:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: statux(MPI_STATUS_SIZE)
 integer :: me,n1,n2,n3,n4,tag
#endif
! *************************************************************************

 ier=0

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 n1 =size(vsend,dim=1)
 n2 =size(vsend,dim=2)
 n3 =size(vsend,dim=3)
 n4 =size(vsend,dim=4)
 tag = MOD(mtag, xmpi_tag_ub+1)
 if ( recever == me ) then
   call MPI_RECV(vrecv,n1*n2*n3*n4,MPI_DOUBLE_PRECISION,sender,tag,spaceComm,statux,ier)
 end if
 if ( sender == me ) then
   call MPI_SEND(vsend,n1*n2*n3*n4,MPI_DOUBLE_PRECISION,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_dp4d_tag
!!***

!--------------------------------------------------------------------

!!****f* ABINIT/xexch_mpi_dp5d_tag
!! NAME
!!  xexch_mpi_dp5d_tag
!!
!! FUNCTION
!!  Sends and receives data.
!!  Target: double precision five-dimensional arrays.
!!
!! INPUTS
!!  mtag= message tag
!!  vsend= send buffer
!!  sender= node sending the data
!!  recever= node receiving the data
!!  spaceComm= MPI communicator
!!
!! OUTPUT
!!  ier= exit status, a non-zero value meaning there is an error
!!
!! SIDE EFFECTS
!!  vrecv= receive buffer
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE
subroutine xexch_mpi_dp5d_tag(vsend,mtag,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_dp5d_tag'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) ::mtag 
 real(dp),intent(in) :: vsend(:,:,:,:,:)
 real(dp),intent(inout) :: vrecv(:,:,:,:,:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: me,n1,n2,n3,n4,n5,tag
 integer :: statux(MPI_STATUS_SIZE)
#endif
! *************************************************************************

 ier=0 !

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 n1 =size(vsend,dim=1)
 n2 =size(vsend,dim=2)
 n3 =size(vsend,dim=3)
 n4 =size(vsend,dim=4)
 n5 =size(vsend,dim=5)
 tag = MOD(mtag,xmpi_tag_ub+1)
 if ( recever == me ) then
   call MPI_RECV(vrecv,n1*n2*n3*n4*n5,MPI_DOUBLE_PRECISION,sender,tag,spaceComm,statux,ier)
 end if
 if ( sender == me ) then
   call MPI_SEND(vsend,n1*n2*n3*n4*n5,MPI_DOUBLE_PRECISION,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_dp5d_tag
!!***

!--------------------------------------------------------------------

!!****f* ABINIT/xexch_mpi_spc_1d
!! NAME
!!  xexch_mpi_spc_1d
!!
!! FUNCTION
!!  Sends and receives data.
!!  Target: one-dimensional single precision complex arrays.
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE

subroutine xexch_mpi_spc_1d(vsend,n1,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_spc_1d'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) :: n1
 complex(spc),intent(in) :: vsend(:)
 complex(spc),intent(inout) :: vrecv(:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: statux(MPI_STATUS_SIZE)
 integer :: tag,me
#endif
! *************************************************************************

 ier=0

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL ) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 tag= MOD(n1, xmpi_tag_ub+1)
 if ( recever == me ) then
   call MPI_RECV(vrecv,n1,MPI_COMPLEX,sender, tag,spaceComm,statux,ier)
 end if

 if ( sender == me ) then
   call MPI_SEND(vsend,n1,MPI_COMPLEX,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_spc_1d
!!***

!--------------------------------------------------------------------

!!****f* ABINIT/xexch_mpi_dpc_1d
!! NAME
!!  xexch_mpi_dpc_1d
!!
!! FUNCTION
!!  Sends and receives data.
!!  Target: one-dimensional double precision complex arrays.
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE

subroutine xexch_mpi_dpc_1d(vsend,n1,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_dpc_1d'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) :: n1
 complex(dpc),intent(in) :: vsend(:)
 complex(dpc),intent(inout) :: vrecv(:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: statux(MPI_STATUS_SIZE)
 integer :: tag,me
#endif
! *************************************************************************

 ier=0

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL ) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 tag = MOD(n1, xmpi_tag_ub+1)
 if ( recever == me ) then
   call MPI_RECV(vrecv,n1,MPI_DOUBLE_COMPLEX,sender, tag,spaceComm,statux,ier)
 end if

 if ( sender == me ) then
   call MPI_SEND(vsend,n1,MPI_DOUBLE_COMPLEX,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_dpc_1d
!!***

!--------------------------------------------------------------------

!!****f* ABINIT/xexch_mpi_dpc_2d
!! NAME
!!  xexch_mpi_dpc_2d
!!
!! FUNCTION
!!  Sends and receives data.
!!  Target: two-dimensional double precision complex arrays.
!!
!! PARENTS
!!
!! CHILDREN
!!      mpi_comm_rank,mpi_recv,mpi_send
!!
!! SOURCE

subroutine xexch_mpi_dpc_2d(vsend,nt,sender,vrecv,recever,spaceComm,ier)


 use defs_basis

#if defined HAVE_MPI2 && ! defined HAVE_MPI_INCLUDED_ONCE
 use mpi
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'xexch_mpi_dpc_2d'
!End of the abilint section

 implicit none

#if defined HAVE_MPI1
 include 'mpif.h'
#endif

!Arguments----------------
 integer,intent(in) :: nt
 complex(dpc),intent(in) :: vsend(:,:)
 complex(dpc),intent(inout) :: vrecv(:,:)
 integer,intent(in) :: sender,recever,spaceComm
 integer,intent(out)   :: ier

!Local variables--------------
#if defined HAVE_MPI
 integer :: statux(MPI_STATUS_SIZE)
 integer :: tag,me
#endif
! *************************************************************************

 ier=0

#if defined HAVE_MPI
 if ( sender == recever .or. spaceComm==MPI_COMM_NULL ) return
 call MPI_COMM_RANK(spaceComm,me,ier)
 tag=MOD(nt, xmpi_tag_ub+1)
 if ( recever == me ) then
   call MPI_RECV(vrecv,nt,MPI_DOUBLE_COMPLEX,sender, tag,spaceComm,statux,ier)
 end if

 if ( sender == me ) then
   call MPI_SEND(vsend,nt,MPI_DOUBLE_COMPLEX,recever,tag,spaceComm,ier)
 end if
#endif

end subroutine xexch_mpi_dpc_2d
!!***
