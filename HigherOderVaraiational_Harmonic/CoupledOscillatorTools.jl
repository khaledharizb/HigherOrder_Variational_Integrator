function Coupled_Oscillator(alpha,epsilon)

function KineticEnergy(q,p)
[p[1]; p[2]]
end

function PotentialEnergy(q,p)
[alpha[1]*q[1] - epsilon * (q[1] - q[2]) ; alpha[2]*q[2] - epsilon * (q[2] - q[1])]
end
    
return KineticEnergy, PotentialEnergy;
    
end