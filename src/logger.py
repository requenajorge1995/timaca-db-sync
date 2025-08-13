import logging
import os


def get_logger() -> logging.Logger:
    """Create and return a configured application logger.

    The logger writes to both stdout and a log file at the project root.
    """
    logger = logging.getLogger("timaca_db_sync")
    if logger.handlers:
        return logger

    logger.setLevel(logging.INFO)

    src_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(src_dir)
    log_file_path = os.path.join(project_root, "timaca-db-sync.log")

    formatter = logging.Formatter(
        fmt="%(asctime)s | %(levelname)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    stream_handler = logging.StreamHandler()
    stream_handler.setLevel(logging.INFO)
    stream_handler.setFormatter(formatter)
    logger.addHandler(stream_handler)

    file_handler = logging.FileHandler(log_file_path, encoding="utf-8")
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    logger.propagate = False
    return logger
