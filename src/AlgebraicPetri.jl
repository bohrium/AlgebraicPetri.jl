""" Computing in the category of finite sets and Petri cospans
"""
module AlgebraicPetri
export PetriCospanOb, PetriFunctor, PetriCospan

using Catlab.GAT
using Catlab.Theories: BiproductCategory
using Catlab.CategoricalAlgebra.ShapeDiagrams
using Catlab.CategoricalAlgebra.FinSets
using Petri

import Catlab.Theories: dom, codom, id, compose, ⋅, ∘, otimes, munit, braid,
                        mcopy, mmerge, create, delete, pair, copair, proj1, 
                        proj2, coproj1, coproj2

struct PetriCospanOb
    n::Int
end
Base.eachindex(X::PetriCospanOb) = 1:X.n

struct PetriFunctor
    n::Function
    dom::Int
    codom::Int
end

id(::Type{PetriFunctor}, n::Int) = PetriFunctor(x->x, n, n)
compose(f::PetriFunctor, g::PetriFunctor) = begin
    if f.codom != g.dom
        error("Codomain of f ($(f.codom)) does not match domain of g ($(g.dom))")
    end
    PetriFunctor(g.n ∘ f.n, f.dom, g.codom)
end
⋅(f::PetriFunctor, g::PetriFunctor) = compose(f, g)
∘(f::PetriFunctor, g::PetriFunctor) = compose(g, f)

struct PetriCospan{F<:PetriFunctor, D<:Petri.Model}
    f::DecoratedCospan{F,D}
end

NullPetri(n::Int) = Petri.Model(collect(1:n), Vector{Tuple{Vector{Int}, Vector{Int}}}())

@instance BiproductCategory(PetriCospanOb, PetriCospan) begin
    dom(f::PetriCospan) = PetriCospanOb(dom(left(f.f)).n)
    codom(f::PetriCospan) = PetriCospanOb(dom(right(f.f)).n)

    compose(f::PetriCospan, g::PetriCospan) = begin
        Nothing
    end

    id(X::PetriCospanOb) = PetriCospan(
        DecoratedCospan(
            Cospan(id(FinOrd(X.n)), id(FinOrd(X.n))),
            id(PetriFunctor, X.n),
            NullPetri(X.n)
        )
    )

    otimes(X::PetriCospanOb, Y::PetriCospanOb) = PetriCospanOb(X.n + Y.n)

    otimes(f::PetriCospan, g::PetriCospan) = begin
        Nothing
    end

    munit(::Type{PetriCospanOb}) = PetriCospanOb(0)

    braid(X::PetriCospanOb, Y::PetriCospanOb) = begin
        Nothing
    end

    mcopy(X::PetriCospanOb) = begin
        Nothing
    end

    mmerge(X::PetriCospanOb) = begin
        Nothing
    end

    create(X::PetriCospanOb) = begin
        Nothing
    end

    delete(X::PetriCospanOb) = begin
        Nothing
    end

    pair(f::PetriCospan, g::PetriCospan) = compose(mcopy(dom(f)), otimes(f, g))
    copair(f::PetriCospan, g::PetriCospan) = compose(otimes(f, g), mmerge(codom(f)))

    proj1(A::PetriCospanOb, B::PetriCospanOb) = otimes(id(A), delete(B))
    proj2(A::PetriCospanOb, B::PetriCospanOb) = otimes(delete(A), id(B))

    coproj1(A::PetriCospanOb, B::PetriCospanOb) = otimes(id(A), create(B))
    coproj2(A::PetriCospanOb, B::PetriCospanOb) = otimes(create(A), id(B))
end

end
