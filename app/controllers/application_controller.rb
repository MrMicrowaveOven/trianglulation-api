class ApplicationController < ActionController::API
    RADIUS_OF_EARTH = 3963
    def index
        lat1, lng1, distance1 = params['lat1'].to_f, params['lng1'].to_f, params['distance1'].to_f
        lat2, lng2, distance2 = params['lat2'].to_f, params['lng2'].to_f, params['distance2'].to_f
        lat3, lng3, distance3 = params['lat3'].to_f, params['lng3'].to_f, params['distance3'].to_f
        equidistant_points = get_equidistant_points(lat1, lng1, distance1)
        render json: { equidistant_points: equidistant_points }
    end

    private

    def get_equidistant_points(lat, lng, distance)
        vert_points = get_vert_points(lat, lng, distance)
        hor_points = get_hor_points(lat, lng, distance)

        north_lat = vert_points[0][0]
        east_lng = hor_points[1][1]
        vert_angular_distance = north_lat - lat
        hor_angular_distance = east_lng - lng
        diag_points = get_diag_points(lat, lng, vert_angular_distance, hor_angular_distance)

        vert_points + hor_points + diag_points
    end

    def get_vert_points(lat, lng, distance)
        degrees_to_move_radians = distance / RADIUS_OF_EARTH
        degrees_to_move = degrees_to_move_radians * 180 / Math::PI
        [[lat + degrees_to_move, lng], [lat - degrees_to_move, lng]]
    end

    def get_hor_points(lat, lng, distance)
        lat_in_radians = lat * Math::PI / 180
        radius_at_latitude = RADIUS_OF_EARTH * Math.cos(lat_in_radians)
        degrees_to_move_radians = distance / radius_at_latitude
        degrees_to_move = degrees_to_move_radians * 180 / Math::PI
        [[lat, lng - degrees_to_move], [lat, lng + degrees_to_move]]
    end

    def get_diag_points(lat, lng, vert_angular_distance, hor_angular_distance)
        vert_angular_distance_of_diags = vert_angular_distance / Math.sqrt(2)
        hor_angular_distance_of_diags = hor_angular_distance / Math.sqrt(2)
        [
            [lat + vert_angular_distance_of_diags, lng + hor_angular_distance_of_diags],
            [lat - vert_angular_distance_of_diags, lng + hor_angular_distance_of_diags],
            [lat - vert_angular_distance_of_diags, lng - hor_angular_distance_of_diags],
            [lat + vert_angular_distance_of_diags, lng - hor_angular_distance_of_diags],
        ]
    end
end
