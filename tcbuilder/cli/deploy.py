import os

from tcbuilder.backend import deploy
from tcbuilder.errors import InvalidArgumentError, InvalidStateError, PathNotExistError


def progress_update(asyncprogress, _user_data=None):
    """ Update progress status

        self:
            asyncprogress (OSTree.AsyncProgress) - object with progress information
            user_data - additional data (not used)
    """
    bytes_transferred = asyncprogress.get_uint64("bytes-transferred")

    print("Pull: %s bytes transferred.\r", str(bytes_transferred))


def deploy_tezi_image(args):
    output_dir = os.path.abspath(args.output_directory)

    storage_dir = os.path.abspath(args.storage_directory)
    tezi_dir = os.path.join(storage_dir, "tezi")
    src_sysroot_dir = os.path.join(storage_dir, "sysroot")
    src_ostree_archive_dir = os.path.join(storage_dir, "ostree-archive")

    dst_sysroot_dir = os.path.abspath(args.deploy_sysroot_directory)

    if os.path.exists(output_dir):
        raise InvalidStateError(f"Output directory {output_dir} must not exist.")

    if not os.path.exists(dst_sysroot_dir):
        raise PathNotExistError(f"Deploy sysroot directory {dst_sysroot_dir} does not exist.")

    deploy.deploy_tezi_image(tezi_dir, src_sysroot_dir, src_ostree_archive_dir,
                             output_dir, dst_sysroot_dir, args.ref)

def deploy_ostree_remote(args):
    storage_dir = os.path.abspath(args.storage_directory)
    src_ostree_archive_dir = os.path.join(storage_dir, "ostree-archive")

    deploy.deploy_ostree_remote(args.remote_host, args.remote_username,
                                args.remote_password, args.mdns_source,
                                src_ostree_archive_dir, args.ref, args.reboot)

def deploy_image(args):
    if args.output_directory is not None:
        deploy_tezi_image(args)
    elif args.remote_host is not None:
        deploy_ostree_remote(args)
    else:
        raise InvalidArgumentError(
            "One of the following arguments is required: --output-directory, --remote-host")


def init_parser(subparsers):
    subparser = subparsers.add_parser("deploy", help="""\
    Deploy the current image as a Toradex Easy Installer image""")
    subparser.add_argument("--output-directory", dest="output_directory",
                           help="""Output path for TorizonCore Toradex Easy Installer image.""")

    subparser.add_argument("--remote-host", dest="remote_host",
                           help="""Remote host machine to deploy to.""")
    subparser.add_argument("--remote-username", dest="remote_username",
                           help="""user name of remote machine""",
                           default="torizon")
    subparser.add_argument("--remote-password", dest="remote_password",
                           help="""password of remote machine""")
    subparser.add_argument("--mdns-source", dest="mdns_source",
                           help="""Use the given IP address as mDNS source.
                           This is useful when multiple interfaces are used, and
                           mDNS multicast requests are sent out the wrong
                           network interface.""")
    subparser.add_argument("--reboot", dest="reboot", action='store_true',
                           help="""Reboot machine after deploying""",
                           default=False)

    subparser.add_argument(metavar="REF", nargs="?", dest="ref",
                           help="""OSTree reference to deploy.""")
    subparser.add_argument("--deploy-sysroot-directory", dest="deploy_sysroot_directory",
                           help="""Work directory to store the intermittent deployment sysroot.
                           NOTE: OSTree need to be able to write extended
                           attributes in this directory. This seems to only
                           reliably work when using a Docker volume!
                           """,
                           default="/deploy")

    subparser.set_defaults(func=deploy_image)

