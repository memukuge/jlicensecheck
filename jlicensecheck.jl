using Pkg
Pkg.add("Gumbo")
using Gumbo 
Pkg.add("HTTP")
using HTTP
Pkg.add("Cascadia")
using Cascadia

url =ARGS[1]
#url = "http://juliapackages.com/p/cuda"
#url = "https://juliapackages.com/p/abstractffts"


function getGithubFromPackage(purl)
    res = HTTP.get(purl)
    doc = parsehtml(String(res.body))
    #github = doc.root[2][1][2][1][1][1][2][1][2][1]
    #githubUrl = getattr(github,"href")
    githubTag = eachmatch(Selector("[href#=(github.com)]"),doc.root[2][1][2][1][1][1][2])
    githubUrl = getattr(githubTag[1],"href")
    return githubUrl 
end



function getLisenceFromGithub(gurl)
    gres = HTTP.get(gurl)
    gdoc = parsehtml(String(gres.body))
    #lisenceElement = gdoc.root[2][5][1][1][2][1][2][1][4][2][1][1][1][9][1]
    #lisenceUrl = getattr(lisenceElement,"href")
    #lisenceStr = strip(string(lisenceElement[2]))
    licenseElement  = eachmatch(Selector(".Layout-sidebar"),gdoc.root[2])
    licenseElement  = eachmatch(Selector(".Link--muted"),gdoc.root[2])
    licenseTag = licenseElement[3]
    licenseStr = strip(string(licenseTag[2]))
    licenseUrl = getattr(licenseTag,"href","NO LINK")
    return licenseStr, licenseUrl
end


function getLicenses()
    i = 1
    for u in depUrls
        gurl =getGithubFromPackage("https://juliapackages.com" * string(u))
        
        l, lurl = getLisenceFromGithub(gurl)
        println(depNames[i] * "," * l * ", " *gurl * ",https://github.com" * lurl)
        i = i + 1
    end
end


res = HTTP.get(url)
doc = parsehtml(String(res.body))
deepDependencyCheck = doc.root[2][1][2][2][1][3][1][1][1][1][2][1][1]
#getattr(deepDependencyCheck,"x-data")
setattr!(deepDependencyCheck,"x-data","{ value: true, toggle() { this.value = !this.value ; \$('.js-toggle__depending').trigger('toggleDependency', this.value) } ")
deepDependency = doc.root[2][1][2][2][1][3][1][1][2]

depNames=[]
names = eachmatch(Selector(".text-sm"),deepDependency)
for n in names
    nn= strip(string(n[1]))
    push!(depNames,nn)
    #println(nn)
end

depUrls=[]
urls = eachmatch(Selector(".ease-in-out"),deepDependency)
for u in urls
    uu = getattr(u,"href")
    uuu = strip(string(uu))
    push!(depUrls,uuu)
end

getLicenses()
