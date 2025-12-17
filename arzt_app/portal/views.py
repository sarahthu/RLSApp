from django.shortcuts import render

def startseite(request):
    return render(request, 'portal/startseite.html')

def home(request):
    return render(request, 'portal/home.html')

def dokumentation(request):
    return render(request, 'portal/dokumentation.html')

def einstellungen(request):
    return render(request, 'portal/einstellungen.html')

def profil(request):
    return render(request, 'portal/profil.html')
