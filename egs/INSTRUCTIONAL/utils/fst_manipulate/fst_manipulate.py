import pywrapfst as openfst
import re


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
        raise Exception("{} not in symbols".format(word))


def sequence_to_fst(seq_string, sym_table):
    """
    Builds an `fst` to represent a test sentence
    :param seq_string: <str> of the sequence
    :param sym_table: symbol table from existing fst
                        existing_fst.input_symbols()
    :return: <openfst.Fst> representing the sequence
    """
    # initialize the fst
    sentence_fst = openfst.Fst()
    states = {}
    # add start state
    states["start"] = sentence_fst.add_state()
    sentence_fst.set_start(states["start"])

    # convert sequence <str> to <list> of indexes
    #  add <s>
    sentence_idxs = [lookup_word("<s>", sym_table)]
    # add words in sequence
    sentence_idxs.extend([lookup_word(w, sym_table) for w in seq_string.lower().split()])
    # add </s>
    sentence_idxs.append(lookup_word("</s>", sym_table))

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
    seq_fst = sequence_to_fst(seq_string, lm_fst.input_symbols())
    return openfst.compose(lm_fst, seq_fst)