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


class YASHEComplexity(HESchemeComplexity) :
    """ Classe representant le HE scheme: YASHEComplexity. """

    def __init__(self, listOfParams, listOfSets, flag = "HEBasic", file = "", complexity = Complexity()) :
        self.builder = Builder()
        self.finder = Finder()

        #Sets and input parameters lists
        [self.R, self.Xerr, self.Xkey] = listOfSets
        [self.q, self.d, self.w, self.t, self.bErr, self.bKey, self.delta, self.l, self.quotient] = self.defineInParams(listOfParams)

        HESchemeComplexity.__init__(self, [self.q, self.d, self.w, self.t, self.bErr, self.bKey, self.delta, self.l, self.quotient], listOfSets, complexity)

        #Definition of Atomics and Specifics available in PAnTHErS library
        self.add = self.finder.atomic(self.heKeyGen.allAtomics, "add")
        self.mult = self.finder.atomic(self.heKeyGen.allAtomics, "mult")
        self.sub = self.finder.atomic(self.heKeyGen.allAtomics, "sub")
        self.rand = self.finder.atomic(self.heKeyGen.allAtomics, "rand")
        self.mod = self.finder.atomic(self.heMult.allAtomics, "mod")
        self.pow = self.finder.atomic(self.heKeyGen.allAtomics, "pow")
        self.digits = self.finder.atomic(self.heKeyGen.allAtomics, "digits")
        self.prodScal = self.finder.atomic(self.heMult.allAtomics, "prodScal")
        self.div = self.finder.atomic(self.heMult.allAtomics, "div")
        self.round = self.finder.atomic(self.heMult.allAtomics, "round")
        self.inv = self.finder.atomic(self.heMult.allAtomics, "inv")

        self.addTimes = self.finder.specific(self.heKeyGen.allSpecifics, "addTimes")
        self.distriLWE = self.finder.specific(self.heKeyGen.allSpecifics, "distriLWE")
        self.powersOf = self.finder.specific(self.heKeyGen.allSpecifics, "powersOf")
        self.doubleDistriLWE = self.finder.specific(self.heEnc.allSpecifics, "doubleDistriLWE")
        self.changeMod = self.finder.specific(self.heDec.allSpecifics, "changeMod")
        self.prodOfAdd = self.finder.specific(self.heMult.allSpecifics, "prodOfAdd")
        self.wordDecomp = self.finder.specific(self.heMult.allSpecifics, "wordDecomp")
        self.doubleMod = self.finder.specific(self.heMult.allSpecifics, "doubleMod")
        self.prodScalMod = self.finder.specific(self.heMult.allSpecifics, "prodScalMod")
        self.pubKeyGen = self.finder.specific(self.heMult.allSpecifics, "pubKeyGen")
        self.doubleMultInv = self.finder.specific(self.heMult.allSpecifics, "doubleMultInv")
        self.randMultMod = self.finder.specific(self.heMult.allSpecifics, "randMultMod")
        self.wordDecompInv = self.finder.specific(self.heMult.allSpecifics, "wordDecompInv")
        self.flatten = self.finder.specific(self.heMult.allSpecifics, "flatten")
        self.modCenterInZero = self.finder.specific(self.heMult.allSpecifics, "modCenterInZero")
        self.msbToPolynomial = self.finder.specific(self.heMult.allSpecifics, "msbToPolynomial")

        #Creation of the 5 HEBasicFunctionComplexity
        self.keyGen(flag, file)
        self.enc(flag, file)
        self.dec(flag, file)
        self.addHE(flag, file)
        self.multHE(flag, file)

    def defineInParams(self, listOfParams) :
        """ list: list of values
            Changes values (input parameters of YASHE) into Parameter objects.
            Order of Parameter list :
                q, d, w, t, bErr, bKey, delta, l, quotient"""

        q = self.builder.parameter("q", "int", listOfParams[0], 1, 1)
        d = self.builder.parameter("d", "int", listOfParams[1], 1, 1)
        w = self.builder.parameter("w", "int", listOfParams[2], 1, 1)
        t = self.builder.parameter("t", "int", listOfParams[3], 1, 1)
        bErr = self.builder.parameter("bErr", "int", listOfParams[4], 1, 1)
        bKey = self.builder.parameter("bKey", "int", listOfParams[5], 1, 1)
        delta = self.builder.parameter("delta", "int", floor(listOfParams[0]/listOfParams[3], bits=1000), 1, 1)
        l = self.builder.parameter("l", "int", floor(log(listOfParams[0], listOfParams[2]), bits=1000) + 1, 1, 1)
        quotient = self.builder.parameter("quotient", "poly", (self.R.gen())^(d.value)+1, 1, 1, d.value)

        return [q, d, w, t, bErr, bKey, delta, l, quotient]

    def keyGen(self, flag, file) :
        """ Defines HEKeyGenComplexity object which has :
            - a list of Parameter inputs
            - a function containing operation of key generation.
            - Complexity object
            Outputs (keys generated) are put in self.inputs of the HEScheme class.
            """
        self.heKeyGen = self.builder.heKeyGenComplexity()
        self.heKeyGen.complexity = Complexity(flag, file)

        self.heKeyGen.inputs = self.inputs
        sk = self.builder.key("PrivateKey", "poly",0,1,1)
        pk = self.builder.key("PublicKey", "poly",0,1,1)
        evk = self.builder.key("EvaluationKey", "matrixPoly",0,self.l,1)
        self.heKeyGen.outputs = [sk,pk,evk]

        def ope(inputs = self.inputs, sets = self.sets, complexity = self.heKeyGen.complexity) :
            self.heKeyGen.complexity.reset()
            #Private key generation
            z = self.R.gen()
            Rq.<z> = PolynomialRing(ZZ.quo(self.q.value))

            [sk] = self.randMultMod.ope([self.t,self.q], [self.Xkey, self.R, Rq], ["PrivateKey_"+self.heKeyGen.count.str()], complexity)
            sk = Key(sk)

            #Public key generation
            [pk] = self.rand.ope([1,1,self.d], [self.Xkey, Rq], ["PublicKey_"+self.heKeyGen.count.str()], complexity)
            [pk] = self.doubleMultInv.ope([self.t, pk, sk, self.quotient, self.q], [self.R], [pk], complexity)
            pk = Key(pk)

            #Evaluation key generation
            [tmp1, tmp3] = self.distriLWE.ope([self.l, 1, 1, self.d, pk, self.q],[self.R, self.Xerr, self.Xerr],["TmpHEBasicKeyGen_b_" + self.heKeyGen.count.str(), "TmpHEBasicKeyGen_A_" + self.heKeyGen.count.str()], complexity)
            [tmp1] = self.mod.ope([tmp1, self.q], [tmp1], complexity)
            [tmp2] = self.powersOf.ope([sk, self.w, self.q],[self.R],["TmpHEBasicKeyGen_c_" + self.heKeyGen.count.str()], complexity)
            [tmp2] = self.mod.ope([tmp2, self.q], [tmp2], complexity)
            [evk] = self.add.ope([tmp1, tmp2], ["EvaluationKey_"+self.heKeyGen.count.str()], complexity)
            evk = Key(evk)

            self.inputs = self.inputs + [sk,pk,evk]
            self.heKeyGen.count = self.heKeyGen.count + 1
            complexity.printInFile(self.heKeyGen, "KeyGen : ")

        self.heKeyGen.ope = ope

    def enc(self, flag, file) :
        """ Defines HEEncComplexity object which has :
            - a list of Parameter inputs
            - a function containing operation of key generation.
            - a list of Parameter outputs
            - Complexity object
            """
        self.heEnc = self.builder.heEncComplexity()
        self.heEnc.complexity = Complexity(flag, file)

        self.heEnc.inputs = [self.builder.message("InEnc_" + self.heEnc.count.str(), "plain", "poly",0,1,1,0)]
        self.heEnc.outputs = [self.builder.message("OutEnc_" + self.heEnc.count.str(), "cipher", "poly",0,1,1, 0)]

        def ope(inputs, outputs = self.heEnc.outputs, complexity = self.heEnc.complexity) :
            self.heEnc.complexity.reset()

            pk = self.get_input("PublicKey_"+(self.heKeyGen.count-1).str())
            [m] = inputs
            if not(isinstance(outputs[0], Parameter)) :
                outputs[0] = self.builder.message(outputs[0], "cipher", "poly", 0,1,1,0)

            [tmp, tmp1] = self.distriLWE.ope([1, 1, 1, self.d, pk, self.q],[self.R, self.Xerr, self.Xerr],["TmpHEBasicEnc_b_" + self.heEnc.count.str(), "TmpHEBasicEnc_A_" + self.heEnc.count.str()], complexity)

            [tmp] = self.mod.ope([tmp, self.q], [tmp], complexity)
            [tmp] = self.mod.ope([tmp, self.quotient], [tmp], complexity)
            [tmp] = self.mod.ope([tmp, self.q], [tmp], complexity)

            outputs = self.addTimes.ope([tmp, self.delta, m], [outputs[0]], complexity = complexity)
            outputs = self.mod.ope([outputs[0], self.q],[outputs[0]], complexity)

            self.heEnc.outputs = [self.builder.message(outputs[0], "cipher", outputs[0].type, outputs[0].value,outputs[0].rows,outputs[0].cols,0, outputs[0].degree)]
            self.heEnc.count = self.heEnc.count + 1
            complexity.printInFile(self.heEnc, "Enc : ")
            return self.heEnc.outputs

        self.heEnc.ope = ope

    def dec(self, flag, file) :
        """ Defines HEDecComplexity object which has :
            - a list of Parameter inputs
            - a function containing operation of key generation.
            - a list of Parameter outputs
            - Complexity object
            """
        self.heDec = self.builder.heDecComplexity()
        self.heDec.complexity = Complexity(flag, file)

        self.heDec.inputs = [self.builder.message("InDec_" + self.heDec.count.str(), "cipher", "poly",0,1,1,0)]
        self.heDec.outputs = [self.builder.message("OutDec_" + self.heDec.count.str(), "plain", "poly",0,1,1,0)]

        def ope(inputs, outputs = self.heDec.outputs, complexity = self.heDec.complexity) :
            self.heDec.complexity.reset()
            sk = self.get_input("PrivateKey_" + (self.heKeyGen.count-1).str())
            c = inputs[0]

            if not(isinstance(outputs[0], Parameter)) :
                outputs[0] = self.builder.message(outputs[0], "plain", "poly", 0,1,1,0)

            if c.aftermult == 1 :
                outputs = self.mult.ope([sk, c],[outputs[0]], complexity)
                outputs = self.mult.ope([sk, outputs[0]],[outputs[0]], complexity)
                outputs = self.mod.ope([outputs[0], self.q], [outputs[0]], complexity)
                outputs = self.mod.ope([outputs[0], self.quotient], [outputs[0]], complexity)
                outputs = self.mod.ope([outputs[0], self.q], [outputs[0]], complexity)
            else :
                outputs = self.mult.ope([sk, c],[outputs[0]], complexity)
                outputs = self.mod.ope([outputs[0], self.q], [outputs[0]], complexity)
                outputs = self.mod.ope([outputs[0], self.quotient], [outputs[0]], complexity)
                outputs = self.mod.ope([outputs[0], self.q], [outputs[0]], complexity)

            outputs = self.changeMod.ope([self.q, self.q, self.t, outputs[0]],[outputs[0]], complexity)

            self.heDec.outputs = [self.builder.message(outputs[0], "plain", outputs[0].type, outputs[0].value,outputs[0].rows,outputs[0].cols,0, outputs[0].degree)]
            self.heDec.count = self.heDec.count + 1
            complexity.printInFile(self.heDec, "Dec : ")
            return self.heDec.outputs

        self.heDec.ope = ope

    def addHE(self, flag, file) :
        """ Defines HEAddComplexity object which has :
            - a list of Parameter inputs
            - a function containing operation of key generation.
            - a list of Parameter outputs
            - Complexity object
            """
        self.heAdd = self.builder.heAddComplexity()
        self.heAdd.complexity = Complexity(flag, file)

        self.heAdd.inputs = [self.builder.message("InHEBasicAdd_c1_" + self.heAdd.count.str(), "cipher", "poly",0,1,1,0), \
                    self.builder.message("InHEBasicAdd_c2_" + self.heAdd.count.str(), "cipher", "poly",0,1,1,0)]
        self.heAdd.outputs = [self.builder.message("OutHEBasicAdd_" + self.heAdd.count.str(), "cipher", "poly",0,1,1,0)]

        def ope(inputs, outputs = self.heAdd.outputs, complexity = self.heAdd.complexity) :
            self.heAdd.complexity.reset()
            [c1, c2] = inputs
            evk = self.get_input("EvaluationKey_"+(self.heKeyGen.count-1).str())

            if not(isinstance(outputs[0], Parameter)) :
                depth = max(c1.depth, c2.depth)
                outputs[0] = self.builder.message(outputs[0], "cipher", "poly",0,1,1, depth)

            if c1.aftermult == 1 :
                [tmp1] = self.wordDecomp.ope([c1,self.w, self.q], ["TmpHEBasicAdd_relin1_" + self.heAdd.count.str()], complexity)
                [tmp1] = self.mult.ope([tmp1,evk], [tmp1], complexity)
                [tmp1] = self.mod.ope([tmp1,self.q], [tmp1], complexity)
            else :
                tmp1 = self.builder.parameter("TmpHEBasicAdd_relin1_" + self.heAdd.count.str(), c1.type, c1.value,c1.rows,c1.cols, c1.degree)

            if c2.aftermult == 1 :
                [tmp2] = self.wordDecomp.ope([c2,self.w, self.q], ["TmpHEBasicAdd_relin2_" + self.heAdd.count.str()], complexity)
                [tmp2] = self.mult.ope([tmp2,evk], [tmp2], complexity)
                [tmp2] = self.mod.ope([tmp2,self.q], [tmp2], complexity)
            else :
                tmp2 = self.builder.parameter("TmpHEBasicAdd_relin2_" + self.heAdd.count.str(), c2.type, c2.value,c2.rows,c2.cols, c2.degree)

            outputs = self.add.ope([tmp1, tmp2],[outputs[0]], complexity)

            self.heAdd.outputs = [self.builder.message(outputs[0], "cipher", outputs[0].type, outputs[0].value,outputs[0].rows,outputs[0].cols, max(c1.depth, c2.depth), outputs[0].degree)]
            self.heAdd.count = self.heAdd.count + 1
            complexity.printInFile(self.heAdd, "AddHE : ")
            return self.heAdd.outputs

        self.heAdd.ope = ope

    def multHE(self, flag, file) :
        """ Defines HEMultComplexity object which has :
            - a list of Parameter inputs
            - a function containing operation of key generation.
            - a list of Parameter outputs
            - Complexity object
            """
        self.heMult = self.builder.heMultComplexity()
        self.heMult.complexity = Complexity(flag, file)

        self.heMult.inputs = [self.builder.message("InHEBasicMult_" + self.heMult.count.str(), "cipher", "poly",0,1,1,0), \
                self.builder.message("InHEBasicMult_" + self.heMult.count.str(), "cipher", "poly",0,1,1,0)]
        self.heMult.outputs = [self.builder.message("OutHEBasicMult_" + self.heMult.count.str(), "cipher", "poly",0,1,1,1)]

        def ope(inputs, outputs = self.heMult.outputs, complexity = self.heMult.complexity) :
            self.heMult.complexity.reset()

            evk = self.get_input("EvaluationKey_"+(self.heKeyGen.count-1).str())
            [c1, c2] = inputs

            if not(isinstance(outputs[0], Parameter)) :
                depth = max(c1.depth, c2.depth)
                outputs[0] = self.builder.message(outputs[0], "cipher", "poly",0,1,1, depth)

            if c1.aftermult == 1 :
                [tmp1] = self.wordDecomp.ope([c1,self.w, self.q], ["TmpHEBasicMult_relin1_" + self.heMult.count.str()], complexity)
                [tmp1] = self.mult.ope([tmp1,evk], [tmp1], complexity)
                [tmp1] = self.mod.ope([tmp1,self.q], [tmp1], complexity)
            else :
                tmp1 = self.builder.parameter("TmpHEBasicMult_relin1_" + self.heMult.count.str(), c1.type, c1.value,c1.rows,c1.cols, c1.degree)

            if c2.aftermult == 1 :
                [tmp2] = self.wordDecomp.ope([c2,self.w, self.q], ["TmpHEBasicMult_relin2_" + self.heMult.count.str()], complexity)
                [tmp2] = self.mult.ope([tmp2,evk], [tmp2], complexity)
                [tmp2] = self.mod.ope([tmp2,self.q], [tmp2], complexity)
            else :
                tmp2 = self.builder.parameter("TmpHEBasicMult_relin2_" + self.heMult.count.str(), c2.type, c2.value,c2.rows,c2.cols, c2.degree)

            outputs = self.mult.ope([tmp1, tmp2],[outputs[0]], complexity)
            outputs = self.mod.ope([outputs[0], self.quotient],[outputs[0]], complexity)

            outputs = self.changeMod.ope([self.q, self.q, self.t, outputs[0]],[outputs[0]], complexity)

            self.heMult.outputs = [self.builder.message(outputs[0], "cipher", outputs[0].type, outputs[0].value,outputs[0].rows,outputs[0].cols, max(c1.depth, c2.depth), outputs[0].degree)]

            self.heMult.outputs[0].depth = self.heMult.outputs[0].depth + 1
            self.heMult.count = self.heMult.count + 1
            self.heMult.outputs[0].aftermult = 1
            complexity.printInFile(self.heMult, "MultHE : ")
            return self.heMult.outputs

        self.heMult.ope = ope

    def depth(self) :
        delta = self.delta.value
        q = self.q.value
        t = self.t.value
        w = self.w.value
        bKey = self.bKey.value
        bErr = self.bErr.value
        l = self.l.value
        d = self.d.value

        res = 1

        freshCipherNoise = d*t*bKey*(2*bErr+q%t/2)

        noise = d * t * (4 + d * t * bKey) * freshCipherNoise + d * d * t * t * bKey * (bKey + t) \
            + d * d * t * l * w * bErr * bKey

        limit = (delta - q%t)/2

        while noise < limit :
            noise = d * t * (4 + d * t * bKey) * noise + d * d * t * t * bKey * (bKey + t) \
                + d * d * t * l * w * bErr * bKey
            res = res + 1

        res = res - 1

        return res

    def __repr__(self):
        return "YASHEComplexity"
