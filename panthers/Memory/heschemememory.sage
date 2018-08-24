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


class HESchemeMemory(HomomorphicObjectMemory) :
    """ HESchemeMemory is composed of:
        - inputs (list of Parameters),
        - sets (list of sets),
        - Memory object
        - 5 HEBasicFunction : 1 HEKeyGenMemory, 1 HEEncMemory, 1 HEDecMemory, 1 HEAddMemory, 1 HEMultMemory"""

    def __init__(self, inputs = [], sets = [], memory = Memory()) :
        HomomorphicObjectMemory.__init__(self, inputs, sets, memory)
        self.builder = Builder()
        self.heKeyGen = self.builder.heKeyGenMemory()
        self.heEnc = self.builder.heEncMemory()
        self.heDec = self.builder.heDecMemory()
        self.heAdd = self.builder.heAddMemory()
        self.heMult = self.builder.heMultMemory()

    def globalMemory(self, q, function, base) :
        totM = self.memory.convertInBase(q, function, base)

        return totM[3]

    def __repr__(self):
        return "HESchemeMemory"
