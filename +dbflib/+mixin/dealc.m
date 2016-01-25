function fun = dealc()
    persistent fun_
    if isempty(fun_)
        fun_ = @(x)x{:};
    end
    fun = fun_;
end
