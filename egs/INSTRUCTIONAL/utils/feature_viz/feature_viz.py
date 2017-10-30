import numpy as np
import kaldi_io_for_python.kaldi_io as io
import matplotlib.pyplot as plt


def read_in_feats(path_to_feats):
    """
    Reads in the features from a `kaldi scp` or `kaldi ark` file
    :param path_to_scp: full/path/to/*.scp
    :return: <dict> of utt_id:features
    """
    dict_ = {}
    if "scp" in path_to_feats:
        for key, mat in io.read_mat_scp(path_to_feats):
            dict_[key] = mat
    else:
        for key, mat in io.read_mat_ark(path_to_feats):
            dict_[key] = mat
    return dict_


def get_num_features(frames):
    """
    Gets number of features from a representation of <n> frames
    :param frames: <ndarray> of shape num_frames x num_features
    :return: int
    """
    return frames.shape[-1]


def get_num_frames(frames):
    """
    Gets number of frames from a represenation of <n> frames
    :param frames: <ndarray> of shape (num_frames x num_features) or (num_features,)
    :return: int
    """
    if len(frames.shape) == 2:
        num_frames = frames.shape[0]
    else:
        num_frames = 1
    return num_frames


def plot_frame(frame):
    """
    Plots the mfcc for a single frame
    :param frame: <numpy.ndarray> of shape num_frames x num_features
    :param frame: <numpy.ndarray> of shape (num_features,)
    :return: plot
    """
    # # determine number of features
    # num_feats = get_num_features(frame)
    # x_range = range(1, num_feats + 1)
    # # determine number of frames
    # num_frames = get_num_frames(frame)
    # # build x axis
    # x = np.array(x_range)
    # # project to 2-d
    # x.shape = (1, x.shape[-1])
    # # duplicate as needed for number of frames
    # xs = np.repeat(x, num_frames, axis=0)
    # # xs = np.reshape(np.array(x_range), (num_frames, len(x_range)))
    # # plot
    # plt.plot(frame)
    # # plt.xticks(x_range)
    # plt.show()
    if len(frame.shape) > 1:
        raise Exception(
            "you appear to be trying to plot {} frames at one time "
            "but this can only plot one at a time".format(frame.shape[0]))
    # determine number of feats
    num_feats = frame.shape[-1]
    # build x ticks
    x_range = range(1, num_feats + 1)
    plt.plot(x_range, frame)
    plt.xticks(x_range)
    plt.ylabel("what does y represent")
    plt.xlabel("feature #")
    plt.show()


def plot_histogram(frames):
    """
    Plots a histogram of values of each feature for any number of frames
    :param frame: <numpy.ndarray> of shape num_frames x num_features
    :return: <num_features> histograms
    """
    # determine number of features and frames
    num_feats = get_num_features(frames)
    num_frames = get_num_frames(frames)
    # get min and max values of frames
    min_ = frames.min()
    max_ = frames.max()
    # transpose frames so that each dimension is all the values of a feature
    frames = np.transpose(frames)
    plt.figure()
    for feat in range(num_feats):
        plt.subplot(num_feats, 1, feat+1)
        plt.hist(
            x=frames[feat],
            bins=num_feats
        )
    plt.show()



