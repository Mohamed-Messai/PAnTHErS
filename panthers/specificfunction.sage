#
# (C) Copyright 2018 - Cyrielle FERON / ENSTA Bretagne.
# Contributor(s) : Cyrielle FERON <cyrielle.feron@ensta-bretagne.org> (2018)
#
#
# This software is governed by the CeCILL 2.1 license under French law and
# abiding by the rules of distribution of free software.  You can  use,
# modify and/ or redistribute the software under the terms of the CeCILL 2.1
# license as circulated by CEA, CNRS and INRIA at the following URL
# "http://www.cecill.info".
#
# As a counterpart to the access to the source code and  rights to copy,
# modify and redistribute granted by the license, users are provided only
# with a limited warranty  and the software's author,  the holder of the
# economic rights,  and the successive licensors  have only  limited
# liability.
#
# In this respect, the user's attention is drawn to the risks associated
# with loading,  using,  modifying and/or developing or reproducing the
# software by the user in light of its specific status of free software,
# that may mean  that it is complicated to manipulate,  and  that  also
# therefore means  that it is reserved for developers  and  experienced
# professionals having in-depth computer knowledge. Users are therefore
# encouraged to load and test the software's suitability as regards their
# requirements in conditions enabling the security of their systems and/or
# data to be ensured and,  more generally, to use and operate it in the
# same conditions as regards security.
#
# The fact that you are presently reading this means that you have had
# knowledge of the CeCILL 2.1 license and that you accept its terms.
#
#


class SpecificFunction(HomomorphicObject):
    """ SpecificFunction is composed of:
        - inputs (list of Parameters),
        - sets (list of sets),
        - operation (in ope function),
        - outputs (list of Parameters)"""

    def __init__(self, name = "NoName", ope = lambda x: 0, inputs = [], sets = [], flag = "HEBasic", file = ""):
        HomomorphicObject.__init__(self, inputs, sets, flag, file)
        self.__ope = ope(self)
        self.__name = name
        self.__count = 0

    @property
    def ope(self) :
        return self.__ope

    @ope.setter
    def ope(self, ope) :
        self.__ope = ope

    @property
    def count(self) :
        return self.__count

    @count.setter
    def count(self, count) :
        self.__count = count

    @property
    def name(self) :
        return self.__name

    @name.setter
    def name(self, name) :
        self.__name = name

    def __repr__(self):
        return "SpecificFunction: number of inputs ({}), number of outputs ({})".format(len(self.__inputs), len(self.__outputs))
