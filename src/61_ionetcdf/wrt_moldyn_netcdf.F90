!{\src2tex{textfont=tt}}
!!****f* ABINIT/wrt_moldyn_netcdf
!! NAME
!! wrt_moldyn_netcdf
!!
!! FUNCTION
!! Write two files for later molecular dynamics analysis:
!!  - MOLDYN.nc (netcdf format) : evolution of key quantities with time (pressure, energy, ...)
!!  - POSABIN : values of coordinates and velocities for the next time step
!!
!! COPYRIGHT
!! Copyright (C) 1998-2012 ABINIT group (FLambert,MT)
!! This file is distributed under the terms of the
!! GNU General Public License, see ~abinit/COPYING
!! or http://www.gnu.org/copyleft/gpl.txt .
!! For the initials of contributors, see ~abinit/doc/developers/contributors.txt.
!!
!! INPUTS
!!  amass(natom)=mass of each atom, in unit of electronic mass (=amu*1822...)
!!  dtset <type(dataset_type)>=all input variables for this dataset
!!  itime=time step index
!!  option=1: write MOLDYN.nc file (netcdf format)
!!         2: write POSABIN file
!!         3: write both
!!  moldyn_file=name of the MD netcdf file
!!  mpi_enreg=informations about MPI parallelization
!!  results_gs <type(results_gs_type)>=results (energy and its components,
!!   forces and its components, the stress tensor) of a ground-state computation
!!  rprimd(3,3)=real space primitive translations
!!  unpos=unit number for POSABIN file
!!  vel(3,natom)=velocities of atoms
!!  xcart(3,natom)=cartesian coordinates of atoms
!!  xred(3,natom)=reduced coordinates of atoms
!!
!! OUTPUT
!!  -- only printing --
!!
!! SIDE EFFECTS
!!
!! PARENTS
!!      mover
!!
!! CHILDREN
!!      handle_ncerr,metric,wrtout,xredxcart
!!
!! SOURCE

#if defined HAVE_CONFIG_H
#include "config.h"
#endif

#include "abi_common.h"

subroutine wrt_moldyn_netcdf(amass,dtset,itime,option,moldyn_file,mpi_enreg,&
&                            results_gs,rprimd,unpos,vel,xcart,xred)

 use m_profiling

 use defs_basis
 use defs_datatypes
 use defs_abitypes
 use m_results_gs
#if defined HAVE_TRIO_NETCDF
 use netcdf
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'wrt_moldyn_netcdf'
 use interfaces_14_hidewrite
 use interfaces_42_geometry
!End of the abilint section

 implicit none

!Arguments ------------------------------------
!scalars
 integer,intent(in) :: itime,option,unpos
 character(fnlen),intent(in) :: moldyn_file
 type(dataset_type),intent(in) :: dtset
 type(MPI_type),intent(in) :: mpi_enreg
 type(results_gs_type),intent(in) :: results_gs
!arrays
 real(dp),intent(in) :: amass(dtset%natom),rprimd(3,3)
 real(dp),intent(in),target :: vel(3,dtset%natom)
 real(dp),intent(in) :: xcart(3,dtset%natom),xred(3,dtset%natom)

!Local variables-------------------------------
!scalars
 integer,save :: ipos=0
 integer :: iatom,ii
#if defined HAVE_TRIO_NETCDF
 integer :: AtomNumDimid,AtomNumId,CelId,CellVolumeId,DimCoordid,DimScalarid,DimVectorid
 integer :: EkinDimid,EkinId,EpotDimid,EpotId,MassDimid,MassId,NbAtomsid,ncerr,ncid
 integer :: PosId,StressDimid,StressId,TensorSymDimid,TimeDimid,TimestepDimid,TimestepId
 logical :: atom_fix
 real(dp) :: ekin,ucvol
 character(len=fnlen) :: ficname
 character(len=500) :: message
 character(len=16) :: chain
#endif
!arrays
#if defined HAVE_TRIO_NETCDF
 integer :: PrimVectId(3)
 real(dp) :: gmet(3,3),gprimd(3,3),rmet(3,3)
 real(dp),pointer :: vcart(:,:),vred(:,:),vtmp(:,:)
#endif

! *************************************************************************

!Only done by master processor, every nctime step
 if (mpi_enreg%me==0.and.dtset%nctime>0) then

!  Netcdf file name
#if defined HAVE_TRIO_NETCDF
   ficname = trim(moldyn_file)//'.nc'
#endif

!  ==========================================================================
!  First time step: write header of netcdf file
!  ==========================================================================
   if (itime==1.and.(option==1.or.option==3)) then

     ipos=0

#if defined HAVE_TRIO_NETCDF

!    Write message
     write(message,'(4a)')ch10,' Open file ',trim(ficname),' to store molecular dynamics information.'
     call wrtout(std_out,message,'COLL')

!    Create netcdf file
     ncerr = nf90_create(ficname, NF90_CLOBBER , ncid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_create')

!    Dimension time for netcdf (time dim is unlimited)
     ncerr = nf90_def_dim(ncid, "time", nf90_unlimited, TimeDimid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_dim')

!    Symetric Tensor Dimension
     ncerr = nf90_def_dim(ncid, "DimTensor", size(results_gs%strten), TensorSymDimid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_dim')

!    Coordinates Dimension
     ncerr = nf90_def_dim(ncid, "DimCoord", size(xcart,1), DimCoordid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_dim')

!    Atoms Dimensions
     ncerr = nf90_def_dim(ncid, "NbAtoms", dtset%natom, NbAtomsid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_dim')

!    Vector Dimension
     ncerr = nf90_def_dim(ncid, "DimVector", 3 , DimVectorid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_dim')

!    Scalar Dimension
     ncerr = nf90_def_dim(ncid, "DimScalar", 1 , DimScalarid)
     if ( ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_dim')

!    Time step and time unit
     ncerr = nf90_def_var(ncid, "Time_step", nf90_double , DimScalarid, TimestepDimid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')
     ncerr = nf90_put_att(ncid, TimestepDimid, "units", "atomic time unit")
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_att')

!    Ionic masses
     ncerr = nf90_def_var(ncid, "Ionic_Mass", nf90_double , NbAtomsid, MassDimid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')
     ncerr = nf90_put_att(ncid, MassDimid, "units", "atomic mass unit")
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_att')

!    Ionic atomic numbers
     ncerr = nf90_def_var(ncid, "Ionic_Atomic_Number", nf90_double , NbAtomsid, AtomNumDimid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')

!    E_pot
     ncerr = nf90_def_var(ncid, "E_pot", nf90_double , TimeDimid, EpotDimid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')
     ncerr = nf90_put_att(ncid, EpotDimid, "units", "hartree")
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_att')

!    E_kin
     ncerr = nf90_def_var(ncid, "E_kin", nf90_double , TimeDimid, EkinDimid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')
     ncerr = nf90_put_att(ncid, EkinDimid, "units", "hartree")
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_att')

!    Stress tensor
     ncerr = nf90_def_var(ncid, "Stress", nf90_double , (/TensorSymDimid,TimeDimid/), StressDimid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')
     ncerr = nf90_put_att(ncid, StressDimid, "units", "hartree/bohr^3")
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_att')

!    Positions
     ncerr = nf90_def_var(ncid, "Position", nf90_double ,(/DimCoordid,NbAtomsid,TimeDimid/), PosId)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')
     ncerr = nf90_put_att(ncid, PosId, "units", "bohr")
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_att')

!    Celerities
     ncerr = nf90_def_var(ncid, "Celerity", nf90_double ,(/DimCoordid,NbAtomsid,TimeDimid/), CelId)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')
     ncerr = nf90_put_att(ncid, CelId, "units", "bohr/(atomic time unit)")
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_att')

!    In case of volume cell constant
     if (dtset%optcell==0) then
!      Primitive vectors
       do ii = 1,3
         write(unit=chain,fmt='(a15,i1)') "PrimitiveVector",ii
         ncerr = nf90_def_var(ncid, trim(chain), nf90_double , DimVectorid, PrimVectId(ii))
         if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')
       end do
!      Cell Volume
       ncerr = nf90_def_var(ncid, "Cell_Volume", nf90_double , DimScalarid, CellVolumeId)
       if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_def_var')
       ncerr = nf90_put_att(ncid, CellVolumeId, "units", "bohr^3")
       if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_att')
     end if

!    Leave define mode and close file
     ncerr = nf90_enddef(ncid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_enddef')
     ncerr = nf90_close(ncid)
     if ( ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_close')
#endif

   end if

!  ==========================================================================
!  Write data to netcdf file (every nctime time step)
!  ==========================================================================
   if (mod(itime, dtset%nctime)==0.and.(option==1.or.option==3)) then

     ipos=ipos+1

#if defined HAVE_TRIO_NETCDF

!    Write message
     write(message,'(3a)')ch10,' Store molecular dynamics information in file ',trim(ficname)
     call wrtout(std_out,message,'COLL')

!    Open netcdf file
     ncerr = nf90_open(ficname, nf90_write, ncid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_open')

!    Time step
     ncerr = nf90_inq_varid(ncid, "Time_step", TimestepId)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
     ncerr = nf90_put_var(ncid, TimestepId, dtset%dtion)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')

!    Ionic masses
     ncerr = nf90_inq_varid(ncid, "Ionic_Mass", MassId)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
     ncerr = nf90_put_var(ncid, MassId, amass, start = (/ 1 /), count=(/dtset%natom/))
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')

!    Ionic atomic numbers
     ncerr = nf90_inq_varid(ncid, "Ionic_Atomic_Number", AtomNumId)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
     ncerr = nf90_put_var(ncid, AtomNumId, dtset%znucl(dtset%typat(:)),start=(/1/),count=(/dtset%natom/))
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')

!    Epot
     ncerr = nf90_inq_varid(ncid, "E_pot", EpotId)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
     ncerr = nf90_put_var(ncid, EpotId, (/results_gs%etotal/), start=(/ipos/),count=(/1/))
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')

!    Ekin
     ekin=zero;atom_fix=(maxval(dtset%iatfix)>0)
     if (dtset%ionmov==1.or.(.not.atom_fix)) then
       vcart => vel
     else
       ABI_ALLOCATE(vcart,(3,dtset%natom))
       ABI_ALLOCATE(vred,(3,dtset%natom))
       vtmp => vel
       call xredxcart(dtset%natom,-1,rprimd,vtmp,vred)
       do iatom=1,dtset%natom
         do ii=1,3
           if (dtset%iatfix(ii,iatom)==1) vred(ii,iatom)=zero
         end do
       end do
       call xredxcart(dtset%natom,+1,rprimd,vcart,vred)
       ABI_DEALLOCATE(vred)
     end if
     do iatom=1,dtset%natom
       do ii=1,3
         ekin=ekin+half*amass(iatom)*vcart(ii,iatom)**2
       end do
     end do
     if (dtset%ionmov/=1.and.atom_fix)  then
       ABI_DEALLOCATE(vcart)
     end if
     ncerr = nf90_inq_varid(ncid, "E_kin", EkinId)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
     ncerr = nf90_put_var(ncid, EkinId, (/ekin/), start = (/ipos/),count=(/1/))
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')

!    Stress tensor
     ncerr = nf90_inq_varid(ncid, "Stress", StressId)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
     ncerr = nf90_put_var(ncid, StressId, results_gs%strten, &
&     start=(/1,ipos/),count=(/size(results_gs%strten)/))
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')

!    Positions
     ncerr = nf90_inq_varid(ncid, "Position", PosId)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
     ncerr = nf90_put_var(ncid, PosId, xcart, start=(/1,1,ipos/), &
&     count=(/size(xcart,1),dtset%natom,1/))
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')

!    Celerities
     ncerr = nf90_inq_varid(ncid, "Celerity", CelId)
     if ( ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
     ncerr = nf90_put_var(ncid, CelId, vel, start=(/1,1,ipos/), &
&     count=(/size(vel,1),dtset%natom,1/)  )
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')

!    In case of volume cell constant
     if (dtset%optcell==0.and.ipos==1) then
!      Primitive vectors
       do ii = 1,3
         write(unit=chain,fmt='(a15,i1)') "PrimitiveVector",ii
         ncerr = nf90_inq_varid(ncid, trim(chain), PrimVectId(ii) )
         if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
         ncerr = nf90_put_var(ncid, PrimVectId(ii), rprimd(:,ii))
         if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')
       end do
!      Cell Volume
       call metric(gmet,gprimd,-1,rmet,rprimd,ucvol)
       ncerr = nf90_inq_varid(ncid, "Cell_Volume" , CellVolumeId)
       if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_inq_varid')
       ncerr = nf90_put_var(ncid, CellVolumeId, ucvol)
       if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_put_var')
     end if

!    Close file
     ncerr = nf90_close(ncid)
     if (ncerr /= nf90_NoErr) call handle_ncerr(ncerr,'nf90_close')
#endif

   end if

!  ==========================================================================
!  Write data to POSABIN file (every nctime time step if option=3)
!  ==========================================================================
   if ((mod(itime, dtset%nctime)==0.and.option==3).or.(option==2)) then

!    Open file for writing
     open(unpos,file='POSABIN',status='replace',form='formatted')

!    Write Positions
     if (dtset%natom>=1) write(unpos,'(a7,3d18.5)') 'xred  ',(xred(ii,1),ii=1,3)
     if (dtset%natom>1) then
       do iatom=2,dtset%natom
         write(unpos,'(7x,3d18.5)') (xred(ii,iatom),ii=1,3)
       end do
     end if

!    Write Velocities
     if (dtset%natom>=1) write(unpos,'(a7,3d18.5)') 'vel  ',(vel(ii,1),ii=1,3)
     if (dtset%natom>1) then
       do iatom=2,dtset%natom
         write(unpos,'(7x,3d18.5)') (vel(ii,iatom),ii=1,3)
       end do
     end if

!    Close file
     close(unpos)

   end if

!  ==========================================================================
!  End if master proc
 end if

!Fake lines
#if !defined HAVE_TRIO_NETCDF
 if (.false.) write(std_out,*) moldyn_file,results_gs%etotal,rprimd(1,1),xcart(1,1)
#endif

end subroutine wrt_moldyn_netcdf
!!***
