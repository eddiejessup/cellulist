module cell_list_3d

    use utils
    use cell_list_shared
    implicit none

! dim
    integer, allocatable, private :: cl(:, :, :, :), cli(:, :, :)
! /dim

contains

subroutine initialise_cl(l, r_cut)
    real(dp), intent(in) :: l, r_cut
    integer :: m

    m = min(int(floor(l / r_cut)), m_max)
    if (allocated(cl) .and. (size(cl, 1) /= size(inters, 1) .or. size(cl, 2) /= m)) deallocate(cl)
    if (allocated(cli) .and. size(cli, 2) /= m) deallocate(cli)
! dim
    if (.not. allocated(cl)) allocate(cl(size(inters, 1), m, m, m))
    if (.not. allocated(cli)) allocate(cli(size(cl, 2), size(cl, 3), size(cl, 4)))
! /dim
end subroutine

subroutine make_inters(r, l, r_cut)
    real(dp), intent(in) :: r(:, :), l, r_cut
    integer :: inds(size(r, 1), size(r, 2)), i, i_cl
! dim
    integer :: x, x_inc, x_dec, y, y_inc, y_dec, z, z_inc, z_dec
! /dim
    real(dp) :: l_half, r_cut_sq

    l_half = l / 2.0_dp
    r_cut_sq = r_cut ** 2
    call initialise_inters(size(r, 2))
    call initialise_cl(l, r_cut)

    inds = r_to_inds(r, l, size(cl, 2))

    cli = 0
    do i = 1, size(r, 2)
! dim
        cli(inds(1, i), inds(2, i), inds(3, i)) = cli(inds(1, i), inds(2, i), inds(3, i)) + 1
        cl(cli(inds(1, i), inds(2, i), inds(3, i)), inds(1, i), inds(2, i), inds(3, i)) = i
    end do

    intersi = 0
    do x = 1, size(cl, 2)
        x_inc = i_wrap(x + 1, size(cl, 2))
        x_dec = i_wrap(x - 1, size(cl, 2))
        do y = 1, size(cl, 3)
            y_inc = i_wrap(y + 1, size(cl, 3))
            y_dec = i_wrap(y - 1, size(cl, 3))
            do z = 1, size(cl, 4)
                z_inc = i_wrap(z + 1, size(cl, 4))
                z_dec = i_wrap(z - 1, size(cl, 4))
                do i_cl = 1, cli(x, y, z)
                    i = cl(i_cl, x, y, z)

                    call core(i, x, y, z)
                    call core(i, x_inc, y, z)
                    call core(i, x_dec, y, z)

                    call core(i, x, y_inc, z)
                    call core(i, x_inc, y_inc, z)
                    call core(i, x_dec, y_inc, z)

                    call core(i, x, y_dec, z)
                    call core(i, x_inc, y_dec, z)
                    call core(i, x_dec, y_dec, z)


                    call core(i, x, y, z_inc)
                    call core(i, x_inc, y, z_inc)
                    call core(i, x_dec, y, z_inc)

                    call core(i, x, y_inc, z_inc)
                    call core(i, x_inc, y_inc, z_inc)
                    call core(i, x_dec, y_inc, z_inc)

                    call core(i, x, y_dec, z_inc)
                    call core(i, x_inc, y_dec, z_inc)
                    call core(i, x_dec, y_dec, z_inc)


                    call core(i, x, y, z_dec)
                    call core(i, x_inc, y, z_dec)
                    call core(i, x_dec, y, z_dec)

                    call core(i, x, y_inc, z_dec)
                    call core(i, x_inc, y_inc, z_dec)
                    call core(i, x_dec, y_inc, z_dec)

                    call core(i, x, y_dec, z_dec)
                    call core(i, x_inc, y_dec, z_dec)
                    call core(i, x_dec, y_dec, z_dec)

                end do
            end do
        end do
    end do

contains

    subroutine core(i, x, y, z)
        integer, intent(in) :: i, x, y, z
        integer :: i_target_cl, i_target

        do i_target_cl = 1, cli(x, y, z)
            i_target = cl(i_target_cl, x, y, z)
! /dim
            if (i_target /= i .and. r_sep_sq(r(:, i), r(:, i_target), l, l_half) < r_cut_sq) then
                intersi(i) = intersi(i) + 1
                inters(intersi(i), i) = i_target
            end if
        end do
        return
    end subroutine

end subroutine

end module