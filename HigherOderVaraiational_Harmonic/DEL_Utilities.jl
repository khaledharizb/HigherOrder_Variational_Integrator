function DiscreteEL(KineticEnergy,PotentialEnergy,nodes,b,c,h)

function Basis(j,t)
        y=1;
         for i in 1:length(nodes)
            if i!=j
             y = y*(t-nodes[i])/(nodes[j]-nodes[i]);    
            end
         end
     return y;
  end 

function dBasis(j,t)
   ForwardDiff.derivative(t->Basis(j,t),t)
end  

lag = map(j-> Basis.(j,c), 1:length(nodes)); lag = reduce(hcat,lag)';

dlag = map(j-> dBasis.(j,c), 1:length(nodes)); dlag = reduce(hcat,dlag)';

function Q(q,i)
sum(map(k -> q[:,k] * lag[k,i], 1:length(nodes)))
end

function Qdot(q,i)
sum(map(k -> q[:,k] * dlag[k,i], 1:length(nodes))) / h; 
end

function DEL(q0, qhalf, q1,i);
   q = hcat(q0, qhalf, q1);
   sum(map(a -> b[a] * KineticEnergy(Q(q,a),Qdot(q,a)) * dlag[i,a] + h * b[a] * PotentialEnergy(Q(q,a),Qdot(q,a)) * lag[i,a],1:length(c)))
end
    
return DEL
    
end



function DELSolve(DEL,q0,qhalf,q1;ftol=1e-14)
    q2guess = [qhalf;q1];
        d = length(q0);
    DELObjective(Q) = [DEL(q0,qhalf,q1,3) + DEL(q1,Q[1:d],Q[d+1:end],1);DEL(q1,Q[1:d],Q[d+1:end],2)]
    return nlsolve(DELObjective, q2guess,autodiff = :forward,ftol=ftol)
    #return NewtonIter(DELObjective,q2guess;TOL=ftol,maxIter=maxIterNewton)
end


function DELSolve(DEL,q0,qhalf,q1,steps;ftol=1e-14)
       d= length(q0);
    trj = zeros((size(q0)[1],2*steps+1))
    trj[:,1]=q0
    trj[:,2]=qhalf
    trj[:,3]=q1
    
 @showprogress   for j = 1:2:2*(steps-1)     
       sol = DELSolve(DEL,trj[:,j],trj[:,j+1],trj[:,j+2],ftol=ftol).zero
    trj[:,j+3] = sol[1:d]
    trj[:,j+4] = sol[d+1:end]
    end
    
    return trj
end


function ConjugateMomenta_p0(DEL,q0,qhalf,q1)
    return  -DEL(q0,qhalf,q1,1);
end

function ConjugateMomenta_p1(DEL,q0,qhalf,q1)
    return   DEL(q0,qhalf,q1,3);
end

function ConjugateMomenta(DEL,traj::Matrix)
   ps = [ConjugateMomenta_p1(DEL,traj[:,i+1],traj[:,i+2],traj[:,i+3]) for i in range(0, step = 2, length=steps)];
   p0 = [ConjugateMomenta_p0(DEL,traj[:,1],traj[:,2],traj[:,3])];
   ps = [p0; ps];
    return reduce(hcat,ps)
end

function Step1(DEL,q0,p0;ftol=1e-14)
    d = length(q0); geuss = [q0 + h * p0 / 2 ; q0 + h * p0];
    objective(Q) = [p0 + DEL(q0,Q[1:d],Q[d+1:end],1);DEL(q0,Q[1:d],Q[d+1:end],2)]
    return nlsolve(objective,geuss,autodiff =:forward,ftol=ftol)
end

function ComputeTrajectory(DEL,q0,p0,steps;ftol=1e-14)
   sol = Step1(DEL,q0,p0).zero; d = length(q0);
   qhalf = sol[1:d] ; q1 = sol[d+1:end];
    return DELSolve(DEL,q0,qhalf,q1,steps,ftol=ftol)
end