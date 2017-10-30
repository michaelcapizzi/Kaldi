import numpy as np
import kaldi_io_for_python.kaldi_io as io
import matplotlib.pyplot as plt
import plotly.offline as py
import plotly.graph_objs as go


def read_in_features(path_to_feats):
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


def read_in_alignments(path_to_alignments_in_phones):
    """
    Reads in an alignments file that has also been run through int2sym.pl
        example:
            ali-to-phones --per-frame=true <mdl> ark:<ali> ark,t:- \|
            int2sym.pl -f 2- <phone_map>
    :param path_to_alignments_in_phones: full/path/to/file
    :return: <dict> of utt_id:[list_of_phones]
    """
    dict_ = {}
    with open(path_to_alignments_in_phones, 'r') as f:
        for line in f:
            line_split = line.rstrip().split()
            utt_id = line_split[0]
            phones = line_split[1:]
            dict_[utt_id] = phones
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


# matplotlib
# def plot_frame(frames, phones=None):
#     """
#     Plots the mfcc for any number of frames
#     :param frames: <numpy.ndarray> of shape num_frames x num_features
#     :param phones: a <list> of phones equal to number of frames
#     :return: plot
#     """
#     # determine number of feats
#     num_feats = get_num_features(frames)
#     # determine number of frames
#     num_frames = get_num_frames(frames)
#     if phones:
#         # check to make sure num_phones == num_frames
#         num_phones = len(phones)
#         if num_phones != num_frames:
#             raise Exception(
#                 "the num_frames ({}) != num_phones ({})".format(num_frames, num_phones)
#             )
#     # build x ticks
#     x_range = range(1, num_feats + 1)
#     plt.xticks(x_range)
#     plt.ylabel("what does y represent")
#     plt.xlabel("feature #")
#     for f in range(num_frames):
#         if phones:
#             label = phones[f]
#         else:
#             label = 'frame {} of {}'.format(f+1, num_frames)
#         plt.plot(x_range, frames[f], alpha=0.5, label=label)
#     plt.legend(
#         loc='upper right',
#         shadow=False,
#         bbox_to_anchor=(1.25, 1),
#         prop={'size': 5}
#     )
#     plt.tight_layout(pad=7)
#     plt.show()

# plotly
def plot_frames(frames, phones=None):
    """
    Plots the mfcc for any number of frames
    :param frames: <numpy.ndarray> of shape num_frames x num_features
    :param phones: a <list> of phones equal to number of frames
    :return: plot
    """
    # determine number of feats
    num_feats = get_num_features(frames)
    # determine number of frames
    num_frames = get_num_frames(frames)
    if phones:
        # check to make sure num_phones == num_frames
        num_phones = len(phones)
        if num_phones != num_frames:
            raise Exception(
                "the num_frames ({}) != num_phones ({})".format(num_frames, num_phones)
            )
    # build x ticks
    x_range = range(1, num_feats + 1)
    traces = {}
    for f in range(num_frames):
        if phones:
            label = 'frame {}/{}: {}'.format(f+1, num_frames, phones[f])
        else:
            label = 'frame {}/{}'.format(f+1, num_frames)
        traces[f] = go.Scatter(
            x=x_range,
            y=frames[f],
            mode='lines',
            name=label
        )
    data = [v for k, v in traces.items()]
    layout = go.Layout(
        title='Visualization of {} frames'.format(num_frames),
        xaxis=dict(
            title='feature number',
            dtick=True
        ),
        yaxis=dict(
            title='what does the value of y mean?'
        )
    )
    figure = go.Figure(data=data, layout=layout)
    py.plot(figure)


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



