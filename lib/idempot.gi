#############################################################################
##
#W  idempot.gi            The Wedderga package            Osnel Broche Cristo
#W                                                        Alexander Konovalov
#W                                                            Aurora Olivieri
#W                                                              �ngel del R�o
##
#H  $Id$
##
#############################################################################


#############################################################################
##
#M eGKH( QG, K, H )
##
##  The function eGKH computes e(G,K,H) for H and K subgroups of G 
##  such that H is normal in K
##
InstallOtherMethod(  eGKH,
                "for pairs of subgroups", 
                true, 
                [ IsSemisimpleRationalGroupAlgebra, IsGroup, IsGroup ], 
                0,
function( QG, K, H )
local   alpha, 
        G, 
        zero, 
        Eps, 
        Cen, 
        RTCen, 
        nRTCen, 
        i, 
        g, 
        NH;
    
    if not(IsSubgroup(UnderlyingMagma(QG),K)) then
        Print("The group algebra does not correspond to the subgroups \n");
        return fail;
    elif not(IsSubgroup(K,H) or IsNormal(K,H)) then
        Print("The second subgroup must be normal in the first one \n");
        return fail;
    fi;

    G:=UnderlyingMagma(QG);
    NH:=Normalizer(G,H);
    Eps:=Epsilon(QG,K,H);
    if (IsCyclic(FactorGroup(K,H)) and IsNormal(NH,K)) then 
        Cen:=NH;
    else 
        Cen := Centralizer( QG, Eps );
    fi;
    RTCen:=RightTransversal(G,Cen); 
 
return Sum(List(RTCen,g->Conjugate(QG,Eps,g)));
end);


#############################################################################
##  
##  eGKH( FqG, K, H, c, ltrace )
##
##  The function eGKH computes e(G, K, H, C) for H and K subgroups of G
##  such that H is normal in K and K/H is cyclic group, and C is a cyclotomic 
##  class of q=|Fq| module n=[K:H] containing generators of K/H.
##  The list ltrace contains information about the trace of a n-th roots of 1.  
##
InstallMethod( eGKH,
                "for pairs of subgroups and one cyclotomic class", 
                true, 
                [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList, IsList ],
                0,
function( FqG, K, H, c, ltrace )
local   G,      # Group
        N,      # Normalizer of H in G
        epi,    # N -->N/H
        QNH,    # N/H
        QKH,    # K/H
        gq,     # Generator of K/H
        C1,     # Cyclotomic class of q module n in K/H
        St,     # Stabilizer of C in K/H
        N1,     # Set of representatives of St by epi
        GN1,    # Right transversal of N1 in G
        Eps;    # Epsilon function

G := UnderlyingMagma(FqG);
N := Normalizer(G,H);
epi := NaturalHomomorphismByNormalSubgroup(N,H);
QNH := Image(epi,N);
QKH := Image(epi,K);
gq := MinimalGeneratingSet(QKH)[1];
C1 := Set(List(c,ii->gq^ii));
St := Stabilizer(QNH,C1,OnSets);
N1 := PreImage(epi,St);
GN1 := RightTransversal(G,N1);
Eps := Epsilon(FqG, K, H, c,ltrace);

return Sum( List( GN1, g -> Conjugate( FqG, Eps, g ) ) );
end);


#############################################################################
##
##  eGKH( FqG, K, H, c )
##
##  The function eGKH computes e( G, K, H, c) for H and K subgroups of G such
##  that H is normal in K and K/H is cyclic group, and C is a cyclotomic class
##  of q=|Fq| module n=[K:H] containing generators of K/H.
##
InstallOtherMethod( eGKH,
   "for pairs of subgroups and one cyclotomic class", 
   true, 
   [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList ],
   0,
function( FqG, K, H, c )
local   G,          # Group
        Fq,         # Field
        q,          # Order of field Fq
        n,          # Order of K/H
        cc,         # Set of cyclotomic classes of q module n
        N,          # Normalizer of H in G
        epi,        # N -->N/H
        QNH,        # N/H
        QKH,        # K/H
        gq,         # Generator of K/H
        C1,         # Cyclotomic class of q module n in K/H
        St,         # Stabilizer of C in K/H
        N1,         # Set of representatives of St by epi
        GN1,        # Right transversal of N1 in G
        Eps;        # epsilon( G, K, H ) 
        
# Initialization

G := UnderlyingMagma(FqG);
Fq := LeftActingDomain(FqG);
q := Size( Fq );

# First we check that FqG is a finite group algebra over finite field 
# Then we check if K is subgroup of G, H is a normal subgroup of K

if not IsSubgroup( G, K ) then
    Error("The group algebra does not correspond to the subgroups!!!");
elif not( IsSubgroup( K, H ) and IsNormal( K, H ) ) then
    Error("The second subgroup must be normal in the first one!!!");
fi;

# Now we check that K/H is a cyclic group 
# Then we check that c is a cyclotomic class of |K/H| module |K/H| and
# and this class in K/H contain generators of K/H

if not IsCyclic( FactorGroup( K, H ) )then
    Error("The factor group of input subgroups must be cyclic!!!");
fi; 
  
n := Index( K, H );
cc := CyclotomicClasses( q, n );

if not c in cc then
    Error("The input class does not correspond to the subgroups!!!");
elif Gcd( c[1], n ) <> 1 then
    Error("The input class is not aproprierty!!!");
fi; 

# Program

if K=H then
    return Hat( FqG, H );
fi;
N := Normalizer(G,H);
epi := NaturalHomomorphismByNormalSubgroup(N,H);
QNH := Image(epi,N);
QKH := Image(epi,K);
gq := MinimalGeneratingSet(QKH)[1];
C1 := Set(List(c,ii->gq^ii));
St := Stabilizer(QNH,C1,OnSets);
N1 := PreImage(epi,St);
GN1 := RightTransversal(G,N1);
Eps := Epsilon(FqG, K, H, c);

return Sum( List( GN1, g -> Conjugate( FqG, Eps, g ) ) );
end);


#############################################################################
##
#M  Epsilon( QG, K, H )
##
##  The function Epsilon compute epsilon(QG,K,H) for H and K subgroups of G
##  such that H is normal in K. If the additional condition that K/H is 
##  cyclic holds, than the faster algorithm is used.
##
InstallOtherMethod( Epsilon,
   "for pairs of subgroups", 
   true, 
   [ IsSemisimpleRationalGroupAlgebra, IsGroup, IsGroup ], 
   0,
function( QG, K, H )

local   L,       # Subgroup of G
        G,       # Group
        Emb,     # Embedding of G in QG
        zero,    # 0 of QG
        Epsilon, # Coefficients of output
        ElemH,   # The elements of H
        OrderH,  # Size of H
        Supp,    # Support of output
        Trans,   # Representatives of Supp module H
        exp,     # Exponent of the elements of Trans as powers of x
        coeff,   # Coefficients of the elements of Trans in Epsilon
        Epi,     # K --> K/H
        KH,      # K/H
        n,       # Order of KH
        y,       # Generator of KH 
        x,       # Representative of preimage of y
        p,       # Set of prime divisors of n
        Lp,      # Length of p
        Comb,    # The direct product [1..p(1)] X [1..p(2)] X .. X [1..[p(Lp)] X H
        i,j,     # Counters
        hatH, 
        MNSKH,   # The set of non trivial minimal normal subgroups of K/H
        q, powersx;

#First we check if K is subgroup of G, H is a normal subgroup of K

if not IsSubgroup( UnderlyingMagma( QG ),K ) then
    Error("The group algebra does not correspond to the subgroups!!!");
elif not( IsSubgroup( K, H ) and IsNormal( K, H ) ) then
    Error("The second subgroup must be normal in the first one!!!");
fi;

# Initialization
G   := UnderlyingMagma( QG );
Emb := Embedding( G, QG );
Epi := NaturalHomomorphismByNormalSubgroup( K, H ) ;
KH  := Image( Epi, K ); 

if IsCyclic(KH) then

    ElemH:=Elements(H);
    OrderH:=Size(H);
    if K=H then
        for i in [1..OrderH] do
            Epsilon :=List([1..OrderH],h->1/OrderH);  
            # If H=K then Epsilon = Hat( QG, H )
            Supp := ElemH;
        od;
    else
        n:=Size(KH);
        y:=Product(IndependentGeneratorsOfAbelianGroup(KH));
        x:=PreImagesRepresentative(Epi,y);
        p:= Set(FactorsInt(n));
        Lp:=Length(p);
        Comb:=Cartesian(List([1..Lp],i->List([1..p[i]])){[1..Lp]});
        exp:=List(Comb,i->Sum(List([1..Lp],j->n/p[j]*i[j])));
        coeff:=List(Comb,
            i->Product(List([1..Lp],j->-1/p[j]+Int(i[j]/p[j]))));
        Supp:=List(Cartesian(exp,ElemH),i->(x^i[1])*i[2]);
        Epsilon:=List(Cartesian(coeff,[1..OrderH]),i->i[1]/OrderH);   
    fi;
    return ElementOfMagmaRing(FamilyObj(Zero(QG)),0,Epsilon,Supp);
else
    Epsilon := Hat( QG, H );
    hatH:=Epsilon;
    MNSKH:=MinimalNormalSubgroups(KH);
    for i in MNSKH do
        L:=PreImage(Epi,i);
        Epsilon:=Epsilon*(hatH-Hat(QG,L));
    od;
fi;

#Output
return Epsilon; 
end);


#############################################################################
##
#M  Epsilon( FqG, K, H, C, ltrace )
##
##  The function Epsilon computes epsilon( K, H, C), for H and K subgroups of G 
##  such that H is normal in K and K/H is cyclic group, and C is a cyclotomic class
##  of q=|Fq| module n=[K:H] containing generators of K/H.
##  The list ltrace contains information about the traces of the n-th roots of 1.   
##
InstallMethod( Epsilon,
   "for pairs of subgroups, one cyclotomic class and traces", 
   true, 
   [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList, IsList ], 
   0,
function(FqG, K, H, c, ltrace)
local   G,      # Group
        Fq,     # Field
        q,      # Order of field Fq
        N,      # Normalizer of H in G
        epi,    # N -->N/H
        QKH,    # K/H
        n,      # Order of K/H
        gq,     # Generator of K/H
        cc,     # Set of cyclotomic classes of q module n
        d,      # Cyclotomic class of q module n   
        tr,     # Element of ltrace
        coeff,  # Coefficients of the output
        supp;   # Coefficients of the output
    
# In this case the conditions are not necesary because this function
# is used as local function of PCIs

# Program
G := UnderlyingMagma(FqG);
Fq := LeftActingDomain(FqG);
q := Size(Fq);
n := Index(K,H);
cc := CyclotomicClasses(q,n);
N := Normalizer(G,H);
epi := NaturalHomomorphismByNormalSubgroup(N,H);
QKH := Image(epi,K);
gq := MinimalGeneratingSet(QKH)[1];
supp := [];
coeff := [];
for d in cc do
    tr := ltrace[1+(-c[1]*d[1] mod n)];
    Append( supp, PreImages( epi, List( d, x -> gq^x ) ) );
    Append( coeff, List( [ 1 .. Size( H ) * Size( d ) ], x -> tr ) );    
od;
coeff:=Inverse(Size(K)*One(Fq))*coeff;

# Output
return ElementOfMagmaRing(FamilyObj(Zero(FqG)), Zero(Fq), coeff, supp);
end);


#############################################################################
##
##  Epsilon( FqG, K, H, c )
##
##  The function Epsilon computes epsilon( K, H, c ) for H and K subgroups of G
##  such that H is normal in K and K/H is cyclic group, and c is a cyclotomic class
##  of q=|Fq| module n=[K:H] containing generators of K/H.
##
InstallOtherMethod( Epsilon,
   "for pairs of subgroups and one cyclotomic class", 
   true, 
   [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList ], 
   0,
function( FqG, K, H, c )
local   G,      # Group
        Fq,     # Field
        q,      # Order of field Fq
        N,      # Normalizer of H in G
        epi,    # N -->N/H
        QKH,    # K/H
        n,      # Order of K/H
        gq,     # Generator of K/H
        g,      # Representative of the preimage of gq by epi
        cc,     # Set of cyclotomic classes of q module n
        a,      # Primitive n-th root of 1 in an extension of Fq
        d,      # Cyclotomic class of q module n
        tr,     # Trace
        coeff,  # Coefficients of the output
        supp,   # Coefficients of the output
        o;      # The  multiplicative order of q module n

# Initialization
G := UnderlyingMagma(FqG);
Fq := LeftActingDomain(FqG);
q := Size(Fq);

# First we check that FqG is a finite group algebra over field finite
# Then we check if K is subgroup of G, H is a normal subgroup of K

if not IsSubgroup( G, K ) then
    Error("The group algebra does not correspond to the subgroups!!!");
elif not( IsSubgroup( K, H ) and IsNormal( K, H ) ) then
    Error("The second subgroup must be normal in the first one!!!");
fi;

# Now we check that K/H is a cyclic group 
# Then we check that c is a cyclotomic class of |Fq| module |K/H| and
# and this class in K/H contain generators of K/H

if not IsCyclic( FactorGroup( K, H ) )then
    Error("The factor group of input subgroups must be cyclic!!!");
fi; 
n := Index(K,H);
cc := CyclotomicClasses(q,n);
if not c in cc then
    Error("The input class does not correspond to the subgroups!!!");
elif Gcd( c[1], n ) <> 1 then
    Error("The cyclotomic class does not contain a generator of the quotient group!!!");
fi; 

# Program

if K=H then
    return Hat( FqG, H );
fi;
N := Normalizer(G,H);
epi := NaturalHomomorphismByNormalSubgroup(N,H);
QKH := Image(epi,K);
gq := MinimalGeneratingSet(QKH)[1];
o  := Size(cc[2]);
a := BigPrimitiveRoot(q^o)^((q^o-1)/n);
supp := [];
coeff := []; 
for d in cc do
    tr := BigTrace(o, Fq, a^(-c[1]*d[1]));
    Append( supp, PreImages( epi, List( d, x -> gq^x ) ) );
    Append( coeff, List( [ 1 .. Size( H ) * Size( d ) ], x -> tr ) );    
od;
coeff:=Inverse(Size(K)*One(Fq))*coeff;

# Output
return ElementOfMagmaRing(FamilyObj(Zero(FqG)), Zero(Fq), coeff, supp);
end);


#############################################################################
##
## Hat( FG, X )
##
## The function Hat computes the element of FG defined by 
## ( 1/|X| )* sum_{x\in X} x 
##
InstallMethod( Hat,
   "for subset", 
   true, 
   [ IsGroupRing, IsObject ], 
   0,
function(FG,X)
local   G,      # Group
        n,      # Size of the set X
        F,      # Field
        one,    # One of F
        quo;    # n^-1 in F

# Initialization        
if not IsFinite( X ) then
  Error("The second input must be finite set!!!"); 
fi;
G := UnderlyingMagma( FG );
if not IsSubset( G, X ) then
  Error("The group algebra does not correspond to the subset!!!"); 
fi;
F := LeftActingDomain( FG );
one := One( F );
n := Size( X );
if not IsUnit( F, n*one ) then
  Error("The order of second input must be a unit of the ring of coefficients!!!"); 
fi;

# Program
quo := Inverse( n * one );
if not IsList( X ) then 
    X := AsList( X );
fi;
return ElementOfMagmaRing( FamilyObj( Zero( FG ) ),
                           Zero( F ),
                           List( [1..n] , i -> quo),
                           X );
end);
