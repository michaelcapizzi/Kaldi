import pywrapfst as openfst
import re
from math import exp


def write_wrapper(fst_, path_out):
    """
    Wraps the native `.draw()` method from `pywrapfst`,
    but edits the `.dot` file in place to be in portrait mode for easier viewing in notebook
    """
    # write out
    fst_.draw(path_out)
    # read in
    dot_in = open(path_out, "r").read()
    # edit orientation
    dot_out = re.sub(r'Landscape', 'Portrait', dot_in)
    with open(path_out, "w") as f:
        f.write(dot_out)


def lookup_word(word, sym_table):
    """
    Gets the index for a word from an existing symbol table
    :param word: <str> to lookup
    :param sym_table: symbol table from existing fst
                        existing_fst.input_symbols()
    :return: <int>
    """
    try:
        return sym_table.find(word)
    except:
        return sym_table.find("<unk>")


def sequence_to_fst(seq_string, lm_fst):
    """
    Builds an `fst` to represent a test sentence
    :param seq_string: <str> of the sequence
    :param lm_fst: <openfst.Fst> of the language model
    :return: <openfst.Fst> representing the sequence
    """
    # initialize the fst
    sentence_fst = openfst.Fst()
    # set SymbolTables from lm fst
    sentence_fst.set_input_symbols(lm_fst.input_symbols().copy())
    sentence_fst.set_output_symbols(lm_fst.output_symbols().copy())

    # symbol table to use for lookup
    lookup_table = lm_fst.input_symbols()

    # begin buildling fst
    states = {}
    # add start state
    states["start"] = sentence_fst.add_state()
    sentence_fst.set_start(states["start"])

    # convert sequence <str> to <list> of indexes
    #  add <s>
    sentence_idxs = [lookup_word("<s>", lookup_table)]
    # add words in sequence
    sentence_idxs.extend([lookup_word(w, lookup_table) for w in seq_string.lower().split()])
    # add </s>
    sentence_idxs.append(lookup_word("</s>", lookup_table))

    # add nodes and arcs for sentence
    for i in range(len(sentence_idxs)):
        if i == len(sentence_idxs) - 1:
            break
        states[i] = sentence_fst.add_state()
        idx = sentence_idxs[i]
        if i == 0:
            # for start state
            sentence_fst.add_arc(
                states["start"],
                openfst.Arc(
                    ilabel=idx,
                    olabel=idx,
                    weight=None,
                    nextstate=states[0]
                )
            )
        elif i != len(sentence_idxs) - 1:
            sentence_fst.add_arc(
                states[i-1],
                openfst.Arc(
                    ilabel=idx,
                    olabel=idx,
                    weight=None,
                    nextstate=states[i]
                )
            )

    # add end state
    states["end"] = sentence_fst.add_state()
    sentence_fst.set_final(states["end"])
    # add final arc
    sentence_fst.add_arc(
        states[i-1],
        openfst.Arc(
            ilabel=sentence_idxs[-1],
            olabel=sentence_idxs[-1],
            weight=None,
            nextstate=states["end"]
        )
    )
    return sentence_fst


def check_sequence(seq_string, lm_fst):
    """
    Checks a sequence against the language model representing the language model
    If the sequence is valid, it will return the composed FST
    If the sequence is not valid, will return None
    :param seq_string: <str> of the sequence
    :param lm_fst: <openfst.Fst> representing the language model
    :return: <openfst.Fst> or None
    """
    seq_fst = sequence_to_fst(seq_string, lm_fst)
    return openfst.compose(lm_fst, seq_fst)


def get_shortest_path(fst_in):
    """
    Generates the shortest path through an FST
    :param fst_in: <openfst.Fst> 
    :return: <openfst.Fst> or None
    """
    try:
        return openfst.shortestpath(fst_in)
    except:
        return None


def calculate_cost(fst_in):
    """
    Calculates the cost of shortest path through an FST
    :param fst_in: <openfst.Fst>
    :return: <float>
    """
    try:
        return float(openfst.shortestdistance(fst_in)[-1].to_string())
    except:
        return None


def convert_neg_log_e(neg_log_e):
    """
    Removes a negative log, base e value from log space and takes its opposite
    :param neg_log_e: the negative log, base e value to convert
    :return: <float>
    """
    return float(exp(-neg_log_e))


def neg_log_e_to_log_10(neg_log_e):
    """
    Converts a negative log likelihood in base e to log base 10
    :param neg_log_e: the negative log likehood to convert
    :return: <float>
    """
    return -(neg_log_e/2.303)


def index_fst(fst_in):
    """

    :param fst_in:
    :return:
    """
    # initialize output dict
    word_dict = {}

    # symbol table to use for lookup
    lookup_table = fst_in.input_symbols()

    # traverse all arcs
    for state in fst_in.states():
        for arc in fst_in.arcs(state):
            from_state = state
            to_state = arc.nextstate
            word = lookup_table.find(arc.ilabel)
            weight = float(arc.weight.to_string())
            dict_ = {
                "from": from_state,
                "to": to_state,
                "weight": weight
                }
            if word not in word_dict:
                word_dict[word] = [dict_]
            else:
                word_dict[word].append(dict_)

    return word_dict