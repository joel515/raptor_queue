ready = ->
  $("#job_config").change ->
    $.ajax
      url: "/jobs/update_versions"
      data:
        config: $("#job_config option:selected").val()
      dataType: "script"

  $("#job_inputfile").change ->
    $("#file-button").text(" " + $("#job_inputfile").val().split('\\').reverse()[0])
    $("#file-button").prepend($('<span></span>').addClass('glyphicon glyphicon-ok'))
    $("#file-button").removeClass("btn btn-ftered btn-md").addClass("btn btn-ftegreen btn-md")

$(document).ready(ready)
$(document).on('page:load', ready)
