!{\src2tex{textfont=tt}}
!!****f* ABINIT/chkint_eq
!! NAME
!! chkint_eq
!!
!! FUNCTION
!! Checks the value of an input integer variable against a list, and
!! write a sophisticated error message when the value does not appear
!! A few conditions might have been checked before calling chkint,
!! and these are mentioned in the error message.
!!
!! See the examples in the NOTES
!!
!! COPYRIGHT
!! Copyright (C) 1998-2012 ABINIT group (XG)
!! This file is distributed under the terms of the
!! GNU General Public License, see ~abinit/COPYING
!! or http://www.gnu.org/copyleft/gpl.txt .
!! For the initials of contributors, see ~abinit/doc/developers/contributors.txt .
!!
!! INPUTS
!! advice_change_cond= if 1, and if an error is detected, will
!!  advice to change the value of the conditions.
!! cond_number= number of conditions checked before calling chkint.
!! cond_string(cond_number)= name of the variables associated to the conditions.
!! cond_values(cond_number)= value of the variables associated to the conditions.
!! input_name=name of the input variable to be checked
!! input_value=value of the input variable to be checked
!! list_number=number of allowed values (maximum 40).
!! list_values=list of allowed values
!! unit=unit number for clean output file
!!
!! OUTPUT
!!  (only side effect)
!!
!! SIDE EFFECT
!! ierr= switch it to 1 if an error was detected. No action otherwise.
!!
!! NOTES
!! cond_values(cond_number) or list_values(list_number)
!! must be between -99 and 999 to be printed correctly.
!!
!! for the time being, at most 3 conditions are allowed.
!!
!! PARENTS
!!      chkinp,print_psps
!!
!! CHILDREN
!!      chkint_prt
!!
!! SOURCE

#if defined HAVE_CONFIG_H
#include "config.h"
#endif

#include "abi_common.h"


subroutine chkint_eq(advice_change_cond,cond_number,cond_string,cond_values,&
&  ierr,input_name,input_value,list_number,list_values,unit)

 use m_profiling

 use defs_basis

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'chkint_eq'
 use interfaces_57_iovars, except_this_one => chkint_eq
!End of the abilint section

 implicit none

!Arguments ------------------------------------
!scalars
 integer,intent(in) :: advice_change_cond,cond_number,input_value,list_number
 integer,intent(in) :: unit
 integer,intent(inout) :: ierr
 character(len=*),intent(in) :: input_name
!arrays
 integer,intent(in) :: cond_values(3),list_values(list_number)
 character(len=*),intent(in) :: cond_string(3)

!Local variables-------------------------------
!scalars
 integer :: ilist,minmax_flag,minmax_value,ok

!******************************************************************
!BEGIN EXECUTABLE SECTION

!Checks the allowed values
 ok=0
 if(list_number>0)then
   do ilist=1,list_number
     if(input_value == list_values(ilist))ok=1
   end do
 end if
 minmax_flag=0
 minmax_value=0

!If there is something wrong, compose the message, and print it
 if(ok==0)then
   call chkint_prt(advice_change_cond,cond_number,cond_string,cond_values,&
&   ierr,input_name,input_value,&
&   list_number,list_values,minmax_flag,minmax_value,unit)
 end if

end subroutine chkint_eq
!!***
